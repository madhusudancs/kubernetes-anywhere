# Contributing

All patches and feedback welcome.

# TODO

1. Don't build and distribute a giant docker image with all the build
   artifacts.
   
    a. Build the binaries inside a docker container, copy the binaries
       into a separate distributable docker image built from the same
       base image as the build container and distribute that image.
2. Consider distributing a single image for infrastructure creation
   and federation components deployment.
3. Rename both the package and the container image names of
   `fetch-svc-endpoint` to `init`.
4. Move the `fetch-svc-endpoint` logic to `Go` to make it more testable.
   Also, add tests for it.
5. Convert the `fetch-svc-endpoint` polling logic to API server `watch`
   logic. It is much easier to reason about that way.
6. Move the `fetch-svc-endpoint` code out of the manifests directory.
7. Once `fetch-svc-endpoint` code is moved out of the manifests directory,
   add everything in the manifests directory to the docker image in the
   Dockerfile instead of individually listing the files and directories.
