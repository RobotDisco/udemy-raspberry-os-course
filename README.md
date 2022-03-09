# Raspberry Pi: Write Your Own Operating System Step by Step code

This is the operating system I have written for the [Raspberry Pi 3/4 ARM64-based course on Udemy](https://www.udemy.com/course/raspberry-pi-write-your-own-operating-system-step-by-step)

## How to install development environment requirements

Install the `aarch64` GNU GCC suite from your package manager. If you want to run this on a real Raspberry Pi, install a serial program like [PuTTY](https://www.ssh.com/academy/ssh/putty/linux). If you want to run  this virtually, install [QEMU](https://www.qemu.org/)

The course has a section with OS-specific instructions for Windows, Ubuntu, and MacOS.

## How to compile

```
make
```

## How to clean up build artifacts

```
make clean
```

## How to run

```
make run
```

## Contributing

This is me working out the content for a course, so please don't contribute anything.

## License
[0BSD](https://choosealicense.com/licenses/0bsd/)