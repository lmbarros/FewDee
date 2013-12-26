/**
 * A simple example showing how to use OpenGL along with FewDee.
 *
 * I suppose that using Direct3D along with FewDee wouldn't be much different,
 * though I never used Direct3D myself. (When I say that it wouldn't be much
 * different, I am talking about the FewDee side; OpenGL and Direct3D APIs are
 * pretty different from each other.)
 *
 * License: $(LINK2 http://opensource.org/licenses/zlib-license, Zlib License).
 *
 * Authors: Leandro Motta Barros
 */

import std.stdio;
import fewdee.all;


// Let me begin with a big disclaimer: this example is half baked. I tested it
// under Linux only, which always use Allegro's OpenGL back end. Under Windows,
// a Direct3D backend is used by default, so you'll probably have to make
// something to force Allegro to use OpenGL if you are using that operating
// system.
//
// Now the bright is: since Allegro is using OpenGL itself, you don't have to do
// anything to create an OpenGL context, open an OpenGL-capable window, and all
// those system-dependent stuff. You just use OpenGL, and that's all.


// And here out code begins, with even more half bakedness. I am manually
// declaring the OpenGL functions and constants I'll use. If you are serious
// about using OpenGL directly along with FewDee, you should use real OpenGL
// bindings. I never used any, but Derelict
// (https://github.com/aldacron/Derelict3) looks like a popular choice. Deimos
// (https://github.com/D-Programming-Deimos/OpenGL) also has some OpenGL
// stuff. And Glad (https://github.com/Dav1dde/glad) looks like another nice
// option.
extern(C)
{
   enum GL_TRIANGLES = 0x0004;
   void glBegin(int);
   void glEnd();
   void glVertex2f(float, float);
   void glColor3f(float, float, float);
}



// This is the function that uses OpenGL directly to draw some stuff (yeah, that
// colored triangle again). If I were writing real code (not some half baked
// example), I'd probably set my own projection matrix; here, I am just using
// what Allegro had set up, which seems to be an orthogonal projection matrix
// with one unit of measurement per pixel (a common setup for 2D).
void drawWithOpenGL()
{
   // Nothing surprising here. Just plain, old-style, immediate mode OpenGL
   // code.
   glBegin(GL_TRIANGLES);

   glColor3f(1.0, 0.0, 0.0);
   glVertex2f(320.0f, 40.0f);

   glColor3f(0.0, 1.0, 0.0);
   glVertex2f(100.0f, 440.0f);

   glColor3f(0.0, 0.0, 1.0);
   glVertex2f(540.0f, 440.0f);

   glEnd();
}


void main()
{
   al_run_allegro(
   {
      // Start the engine.
      scope crank = new fewdee.engine.Crank();

      // When this is set to 'true', we'll exit the main loop.
      bool exitPlease = false;

      // Allocate some resources; we'll draw some stuff using FewDee/Allegro
      // along with the OpenGL things.
      auto bmpBG = new Bitmap("data/interpolators_graphs_bg.png");
      auto theFont = new Font("data/lato-b.otf", 34);

      // Exit when pressing Escape.
      EventManager.addHandler(
         ALLEGRO_EVENT_KEY_DOWN,
         delegate(in ref ALLEGRO_EVENT event)
         {
            if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE)
               exitPlease = true;
         });

      // The drawing function.
      EventManager.addHandler(
         FEWDEE_EVENT_DRAW,
         delegate(in ref ALLEGRO_EVENT event)
         {
            // We start by clearing the background to white, then using the
            // Allegro API do draw a background image.
            al_clear_to_color(al_map_rgb(255, 255, 255));
            bmpBG.draw(0.0, 0.0);

            // Here's our OpenGL code.
            drawWithOpenGL();

            // And then we draw some text over everything, just to give that
            // feeling that one can really mix OpenGL with FewDee/Allegro
            // freely.
            al_draw_text(theFont, al_map_rgb(10, 20, 30), 25, 200,
                         ALLEGRO_ALIGN_LEFT, "Look, ma! An OpenGL triangle!");
         });

      // Create a display
      DisplayManager.createDisplay("main");

      // Run the main loop while 'exitPlease' is true.
      run(() => !exitPlease);

      // Free the resources we allocated in this example.
      bmpBG.free();
      theFont.free();

      // We're done!
      return 0;
   });
}
