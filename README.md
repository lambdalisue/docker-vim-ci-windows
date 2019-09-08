# vim-ci-windows

A docker image for running [Vim][] on CI (Windows container).

## Usage

```
docker run --rm --volume $(pwd):C:\\volume -it lambdalisue/vim-ci-windows
```

If you are using [StefanScherer/windows-docker-machine](https://github.com/StefanScherer/windows-docker-machine), you would probably need to add `C:` prefix on volume like

```
docker run --rm --volume C:$(pwd):C:\\volume -it lambdalisue/vim-ci-windows
```

[Vim]: https://github.com/vim/vim
