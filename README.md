pci-ids-rs
==========

This is a new maintained fork of [lienching/pci-ids.rs](https://github.com/lienching/pci-ids.rs),
which in turn was modified from [woodruffw's usb-ids.rs](https://github.com/woodruffw/usb-ids.rs).
Thanks to all previous authors.

![license](https://img.shields.io/badge/license-MIT-blue)
[![Build Status](https://img.shields.io/github/actions/workflow/status/auyer/pci-ids.rs/ci.yml?branch=main)](https://github.com/auyer/pci-ids.rs/actions?query=workflow%3ACI)
[![Crates.io](https://img.shields.io/crates/v/pci-ids-rs)](https://crates.io/crates/pci-ids-rs)
[![docs.rs](https://docs.rs/pci-ids-rs/badge.svg)](https://docs.rs/pci-ids-rs)
[![Debian package rust-pci-ids](https://img.shields.io/debian/v/rust-pci-ids/sid)](https://tracker.debian.org/pkg/rust-pci-ids)

Cross-platform Rust wrappers for the [PCI ID Repository](https://pci-ids.ucw.cz/).

This library bundles the PCI ID database, allowing platforms other than Linux to query it
as a source of canonical PCI metadata. It is `#![no_std]` and works on any platform
supported by Rust.

## Installation

Add the crate to your `Cargo.toml`:

```toml
[dependencies]
pci-ids-rs = "0.3"
```

Or, with `cargo`:

```sh
cargo add pci-ids-rs
```

The crate requires Rust 1.85 or newer.

## Usage

Iterating over all known vendors:

```rust
use pci_ids_rs::Vendors;

for vendor in Vendors::iter() {
    for device in vendor.devices() {
        println!("vendor: {}, device: {}", vendor.name(), device.name());
    }
}
```

Looking up a device by its vendor and device IDs:

```rust
use pci_ids_rs::Device;

if let Some(device) = Device::from_vid_pid(0x1af4, 0x1000) {
    println!("{} ({:04x}:{:04x})", device.name(), device.vendor().id(), device.id());
}
```

Vendors and classes can likewise be looked up by ID through the `FromId` trait:

```rust
use pci_ids_rs::{Class, FromId, Vendor};

let vendor = Vendor::from_id(0x1af4).unwrap();
let class = Class::from_id(0x08).unwrap();
```

Iterating over all known classes and subclasses:

```rust
use pci_ids_rs::Classes;

for class in Classes::iter() {
    for subclass in class.subclasses() {
        println!("class: {}, subclass: {}", class.name(), subclass.name());
    }
}
```

See the [API documentation](https://docs.rs/pci-ids-rs) for more details.

## License

Licensed under the MIT license ([LICENSE](LICENSE) or <https://opensource.org/licenses/MIT>).
