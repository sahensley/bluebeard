# Bluebeard

A BlueBuild customized Fedora Atomic Desktop

## Images available

The following images are available:

- bluebeard-gnome
- bluebeard-gnome-framework
- bluebeard-kde
- bluebeard-kde-framework

The following labels are available:

- 40
- latest

## Installation

Substitute 'IMAGE-NAME' and 'LABEL' below with real values. 

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and
  policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/sahensley/IMAGE-NAME:LABEL
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/sahensley/IMAGE-NAME:LABEL
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will
still always use the Fedora version specified in `recipe.yml`, so you won't get
accidentally updated to the next major version.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s
[cosign](https://github.com/sigstore/cosign). You can verify the signature by
downloading the `cosign.pub` file from this repo and running the following
command:

```bash
cosign verify --key cosign.pub ghcr.io/sahensley/bluebeard
```

## ISO

An offline ISO can be built using the instructions available
[here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso).
