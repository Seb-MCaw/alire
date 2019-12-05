with Alire;

package Alr.Bootstrap is

   ---------------------
   --  SESSION STATE  --
   ---------------------

   type Session_States is
     (Outside,   -- Not in any Alire context
      Broken,    -- Top-level folder is a single project, invalid TOML file
      Project,   -- Top-level folder is a single project
      Sandbox    -- Top-level folder is a sandbox with several projects
     );
   --  Sandbox mode is not implemented yet

   subtype Valid_Session_States is Session_States range Project .. Sandbox;

   function Session_State return Session_States;
   --  Note that even if you're in a project within a sandbox, result is
   --  sandbox.

   -------------
   --  OTHER  --
   -------------

   procedure Check_Ada_Tools;
   --  Check gprbuild/gnatmake are within reach

   procedure Check_Tool (Exec : String);
   --  Check that some executable is in the path, or print error and die with
   --  exit code 1.

   function Status_Line return String;
   --  One-liner reporting most interesting information

   function No_Dependencies return Types.Platform_Dependencies
     renames Types.No_Dependencies;

end Alr.Bootstrap;
