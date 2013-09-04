FewDee
======

FewDee is an incomplete, experimental, mostly 2D, library focused on
games prototyping. It is written in the [D Programming
Language](http://dlang.org), and uses the good and old [Allegro
Library](http://alleg.sourceforge.net).

FewDee is *incomplete* because it still has rough edges and missing
features.

FewDee is *experimental* because it has one or two unorthodox design
bits, which weren't much tested so far.

FewDee is *mostly 2D* because its own features provide only 2D
support, but you can use OpenGL (and Direct3D. I suppose) code along
it.

FewDee is *focused on games prototyping* because that's the only thing it
was use so far. In the future, it may prove itself capable to be used
in some kinds of "real games".

FewDee is *written in D* because that's the language I am currently
enamored with. It's pretty good, you should try it, too :-)

FewDee *uses Allegro* -- and this is an understatement, as you
actually have to use some of the Allegro API along with FewDee.

Features
--------

Generally, FewDee doesn't require you to use the facilities it
provides. You pick what you like, and use the Allegro API (or roll
your own wrappers) for the rest.

Here is a selection of FewDee features:

* *Event Manager:* Allows to handle low-level events directly; you
  just add (or remove) delegates that get called as events are
  generated.

* *Input Manager:* Abstracts away low-level events ("joystick button
  pressed"), allowing you to deal with high-level game commands
  ("jump") and states ("walking direction"). There are helpers to make
  an user-customizable input system, and to save and restore the input
  configuration.

* *Sprites*: Group sets of related images, configure and play
  animation sequences.

* *Sprite animation events*: Generate events at specific sprite
  animation frames; handle these events to synchronize audio effects
  (or anything else) with animations.

* *Easing functions*: Nice ways to interpolate between values. Easily
  make smooth changes to properties like position, color, scale,
  rotation and sound volume and balance.

* *Main game loops:* Multiple variations of the [main game
  loop](http://www.koonsolo.com/news/dewitters-gameloop/) are
  supported out-of-the box (and you can roll your own, if you wish).

* *State Manager:* The good and old game state idiom. Neatly separate
   the title screen from in-game scree from the inventory screen, from
   the map screen, from...

* *Audio:* Play audio samples and audio streams. Change their volume,
  balance and playing speed.

* *Resource Manager:* Simplifies the task of managing images, sounds,
  fonts and the like.

* *Scene graph:* FewDee includes a very preliminary scene graph
  implementation.

* *Scene graph events:* Generate and handle events when a scene graph
  node is clicked, has the mouse moved over it, etc.


Current State
-------------

FewDee isn't really ready for wide adoption. Sure, you can use it, but
you may find difficulties, especially setting it up and building
it. And I am pretty sure that there *will* be plenty of breaking API
changes in the future.

FewDee is developed under Linux, with near to none testing under
Windows (though Windows support *is* a must for me, and I successfully
used an ancient version of the library under Windows).

It doesn't have a proper build system -- only a half baked
<tt>Makefile</tt>.

It doesn't have a manual, though it has pretty complete inline
documentation and a set of examples.


The Future
----------

As I write this (September 4th, 2013), I have used an early version of
FewDee to develop a single game prototype. After that, I redesigned
and rewrote lots of things that didn't worked well in this first
experiment.

My plan now is to focus on using FewDee on some game prototypes,
instead of working on the library itself. So, the next FewDee updates
are likely to reflect my own needs on those prototypes.

Concerning the usage of Allegro: I am using it because it worked for
me. Right now, I don't have any plans (nor reasons!) to replace it
with something else. That said, in my imagination I have already
flirted with the idea of completely hiding the Allegro API, and even
supporting multiple "backend libraries" ([SDL
2](http://www.libsdl.org) would be an obvious choice).

I don't really have a vision for the future of FewDee. I guess it will
evolve organically, reshaping itself as better ways to do things are
figured out and new features are added. (As with any project, it could
also die -- which also qualifies as "organic", I guess :-) )


Licensing
---------

FewDee is licensed under the [Zlib
license](http://opensource.org/licenses/zlib-license), which is the
same license used by Allegro (and SDL 2, for that matter).


Whodunit
--------

FewDee was designed and implemented by [Leandro Motta
Barros](http://www.stackedboxes.org/~lmb).

Its "official" Mercurial repository is located at
[BitBucket](https://bitbucket.org/lmb/fewdee), and there is a Git
mirror at [GitHub](https://github.com/lmbarros/FewDee).
