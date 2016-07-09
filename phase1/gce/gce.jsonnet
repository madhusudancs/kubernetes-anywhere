function(cfg)
  local tf = import "phase1/tf.jsonnet";
  local p1 = cfg.phase1;
  local gce = p1.gce;
  local names = {
    instance_template: "%(cluster_name)s-minion-instance-template" % p1,
    instance_group: "%(cluster_name)s-minion-group" % p1,
    master_instance: "%(cluster_name)s-master" % p1,
    master_ip: "%(cluster_name)s-master-ip" % p1,
    master_firewall_rule: "%(cluster_name)s-master-https" % p1,
    minion_firewall_rule: "%(cluster_name)s-minion-all" % p1,
    release_bucket: "%s-kube-deploy-%s" % [gce.project, p1.cluster_name],
  };
  local instance_defaults = {
    machine_type: gce.instance_type,
    can_ip_forward: true,
    scheduling: {
      automatic_restart: true,
      on_host_maintenance: "MIGRATE",
    },
    network_interface: [{
      network: "${google_compute_network.network.name}",
      access_config: {},
    }],
  };
  local config_metadata_template = std.toString(cfg {
    master_ip: "${google_compute_address.%s.address}",
    role: "%s",
    phase3+: {
      addons_config: (import "phase3/all.jsonnet")(cfg),
    },
  });
  local kubeconfig(user, cluster, context) =
    std.manifestJson(
      tf.pki.kubeconfig_from_certs(
        user, cluster, context,
        p1.cluster_name + "-root",
        "https://${google_compute_address.%(master_ip)s.address}" % names
    ));
  {
    output: {
      [names.master_ip]: {
        value: "${google_compute_address.%(master_ip)s.address}" % names,
      },
    },
    provider: {
      google: {
        credentials: if std.objectHas(p1, "credentials") then "${file(\"%(credentials)s\")}" % p1 else "",
        project: gce.project,
        region: gce.region,
      },
    },
    resource: {
      google_compute_network: {
        network: {
          name: gce.network,
          auto_create_subnetworks: true,
        },
      },
      google_compute_address: {
        [names.master_ip]: {
          name: names.master_ip,
          region: gce.region,
        },
      },
      google_compute_firewall: {
        ssh_all: {
          name: "ssh-all",
          network: "${google_compute_network.network.name}",
          allow: [{
            protocol: "tcp",
            ports: ["22"],
          }],
          source_ranges: ["0.0.0.0/0"],
        },
        [names.master_firewall_rule]: {
          name: names.master_firewall_rule,
          network: "${google_compute_network.network.name}",
          allow: [{
            protocol: "tcp",
            ports: ["443"],
          }],
          source_ranges: ["0.0.0.0/0"],
          target_tags: ["%(cluster_name)s-master" % p1],
        },
        [names.minion_firewall_rule]: {
          name: names.minion_firewall_rule,
          network: "${google_compute_network.network.name}",
          allow: [
            { protocol: "tcp" },
            { protocol: "udp" },
            { protocol: "icmp" },
            { protocol: "ah" },
            { protocol: "sctp" },
          ],
          source_ranges: [
            "10.0.0.0/8",
            "172.16.0.0/12",
            "192.168.0.0/16",
          ],
          target_tags: ["%(cluster_name)s-minion" % p1],
        },
      },
      google_compute_instance: {
        [names.master_instance]: instance_defaults {
          name: names.master_instance,
          zone: gce.zone,
          tags: [
            "%(cluster_name)s-master" % p1,
            "%(cluster_name)s-minion" % p1,
          ],
          network_interface: [{
            network: "${google_compute_network.network.name}",
            access_config: {
              nat_ip: "${google_compute_address.%(master_ip)s.address}" % names,
            },
          }],
          metadata_startup_script: std.escapeStringDollars(importstr "configure-vm.sh"),
          metadata: {
            "k8s-role": "master",
            "k8s-config": config_metadata_template % [names.master_ip, "master"],
            "k8s-ca-public-key": "${tls_self_signed_cert.%s-root.cert_pem}" % p1.cluster_name,
            "k8s-apisever-public-key": "${tls_locally_signed_cert.%s-master.cert_pem}" % p1.cluster_name,
            "k8s-apisever-private-key": "${tls_private_key.%s-master.private_key_pem}" % p1.cluster_name,
          },
          disk: [{
            image: gce.os_image,
          }],
          service_account: [
            { scopes: ["compute-rw", "storage-ro"] },
          ],
        },
      },
      google_compute_instance_template: {
        [names.instance_template]: instance_defaults {
          name: names.instance_template,
          tags: ["%(cluster_name)s-minion" % p1],
          metadata: {
            "startup-script": std.escapeStringDollars(importstr "configure-vm.sh"),
            "k8s-role": "node",
            "k8s-deploy-bucket": names.release_bucket,
            "k8s-config": config_metadata_template % [names.master_ip, "node"],
            "k8s-node-kubeconfig": kubeconfig(p1.cluster_name + "-node", "local", "service-account-context"),
          },
          disk: [{
            source_image: gce.os_image,
            auto_delete: true,
            boot: true,
          }],
          service_account: [
            { scopes: ["compute-rw", "storage-ro"] },
          ],
        },
      },
      google_compute_instance_group_manager: {
        [names.instance_group]: {
          name: names.instance_group,
          instance_template: "${google_compute_instance_template.%(instance_template)s.self_link}" % names,
          update_strategy: "NONE",
          base_instance_name: "%(cluster_name)s-minion" % p1,
          zone: gce.zone,
          target_size: p1.num_nodes,
        },
      },

      // Public Key Infrastructure
      tls_private_key: {
        [p1.cluster_name + "-" + name]: tf.pki.private_key
        for name in ["root", "node", "master", "admin"]
      },
      tls_self_signed_cert: {
        [p1.cluster_name + "-root"]: tf.pki.tls_self_signed_cert(p1.cluster_name + "-root"),
      },
      tls_cert_request: {
        [p1.cluster_name + "-" + name]: tf.pki.tls_cert_request(p1.cluster_name + "-" + name)
        for name in ["node", "admin"]
      } {
        [p1.cluster_name + "-master"]: tf.pki.tls_cert_request(
          p1.cluster_name + "-master",
          dns_names=[
            "kubernetes",
            "kubernetes.default",
            "kubernetes.default.svc",
            "kubernetes.default.svc.local",
            "kubernetes.default.svc.local",
            names.master_instance,
          ],
          ip_addresses=[
            "${google_compute_address.%(master_ip)s.address}" % names,
            # master service ip, this depends on the cluster cidr
            # so must be changed if/when we allow that to be configured
            "10.0.0.1",
          ]
        ),
      },
      tls_locally_signed_cert: {
        [p1.cluster_name + "-" + name]: tf.pki.tls_locally_signed_cert(p1.cluster_name + "-" + name, p1.cluster_name + "-root")
        for name in ["node", "master", "admin"]
      },
      kubernetes_kubeconfig: {
        [p1.cluster_name]: {
          depends_on: [
            "google_compute_firewall.%(master_firewall_rule)s" % names,
            "google_compute_instance.%(master_instance)s" % names,
          ],
          server: "https://${google_compute_address.%(master_ip)s.address}" % names,
          configdata: kubeconfig(p1.cluster_name + "-admin", p1.cluster_name, p1.cluster_name)
        }
      },
    },
  }
