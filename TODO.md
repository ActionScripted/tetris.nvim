# TODO

- [ ] docs: use kdheepak/panvimdoc or equivalent
- [ ] feat(core): add chaos mode ( piece swap mid-drop, broken UI, noclip, etc.)
- [ ] feat(core): add options for classic and modern systems
- [ ] feat(state): load game state from file
- [ ] feat(state): save game state to file
- [ ] feat(ui): add game over screen
- [ ] feat(ui): add pause screen
- [ ] feat(ui): add start screen
- [ ] perf(core): decouple game (loop) tick from level/speed
- [ ] perf(core): double buffer for rendering
- [ ] perf(renderer): verify extmark use and cleanup in draw_shape
- [ ] test(core): add tests

## DONE

- [x] feat(core): add pieces
- [x] feat(input): add piece movement
- [x] feat(input): add piece rotation
- [x] feat(pieces): change colors and/or support themes
- [x] feat(ui): add next piece preview
- [x] feat(ui): add score info
- [x] feat(ui): hide cursor/input/block
- [x] feat(ui): namespace for highlights
- [x] perf(core): should we try virtual text?
- [x] perf(ui): are we creating thousands of extmarks?

## SUPER STRETCH

This is just Lua. There's no reason it can't be a standalone Tetris that happens to support being run in Neovim. Maybe we have support for multiple inputs and renderers: NeoVim and standard terminal. Honestly might not be too bad, but I haven't really finished the NeoVim bit so why am I even writing this.
