# TODO

- [ ] docs: use kdheepak/panvimdoc or equivalent
- [ ] feat(core): add options for classic and modern systems
- [ ] feat(core): add pieces
- [ ] feat(input): add piece movement
- [ ] feat(input): add piece rotation
- [ ] feat(pieces): change colors and/or support themes
- [ ] feat(ui): add game over screen
- [ ] feat(ui): add next piece preview
- [ ] feat(ui): add pause screen
- [ ] feat(ui): add score info
- [ ] feat(ui): add start screen
- [ ] feat(ui): hide cursor/input/block
- [ ] feat(ui): namespace for highlights
- [ ] perf(core): decouple game (loop) tick from level/speed
- [ ] perf(core): double buffer for rendering
- [ ] perf(core): should we try virtual text?
- [ ] perf(ui): are we creating thousands of extmarks?
- [ ] test(core): add tests

## SUPER STRETCH

This is just Lua. There's no reason it can't be a standalone Tetris that happens to support being run in Neovim. Maybe we have support for multiple inputs and renderers: NeoVim and standard terminal. Honestly might not be too bad, but I haven't really finished the NeoVim bit so why am I even writing this.
