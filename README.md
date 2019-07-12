# OCHoloLibs
Library set for useful OCGlasses functions and objects

Currently WIP, but feel free to use them as you see fit.

## Usage

The API is still in flux, so breakage may occur.

### `holo.lua`

This can be imported using `require()` like other libraries.

`holo.addComponent(<comp>)` - Passing a hololib component will automatically add it to hololib.  Example: `holo.addComponent('menu')` will add the holo-menu component to hololib.  Component names are passed without the preceding `holo-`

`holo.setupTerminal(<addr>)` - attach an OCGlasses terminal to hololib.  Will reset the glasses before use.

`holo.redraw()` - redraws all bound components.

`holo.save()` - saves component configs.  Not all components support saving.

`holo.load()` - loads existing componnet configs.  Will automatically attempt to add required components using `addComponent`.

`holo.addAdmin(<user>)` - adds a user as an admin.  For secure interact options.

`holo.removeAdmin(<user>)` - removes a user as an admin.  For secure interact options.
