with Alire.Directories;
with Alire.Index_On_Disk.Git;
with Alire.TOML_Keys;
with Alire.Utils;
with Alire.VCSs;

package body Alire.Index_On_Disk is

   type Invalid_Index is new Index with null record;

   function Add (This : Invalid_Index) return Outcome is
     (raise Program_Error);

   function New_Handler (Origin : URL;
                         Name   : Restricted_Name;
                         Parent : Platform_Independent_Path)
                            return Invalid_Index;

   function Update (This : Invalid_Index) return Outcome is
     (raise Program_Error);

   ----------
   -- Load --
   ----------

   function Load (This : Index'Class;
                  Env  : Alire.TOML_Index.Environment_Variables) return Outcome
   is
      Repo_Version_Files : constant Utils.String_Vector :=
                             Directories.Find_Files_Under
                               (Folder    => This.Index_Directory,
                                Name      => "index.toml",
                                Max_Depth => 1);
   begin
      case Natural (Repo_Version_Files.Length) is
         when 0 =>
            return Outcome_Failure ("No index.toml file found in index");
         when 1 =>
            Trace.Detail ("Loading index found at " &
                            Repo_Version_Files.First_Element);

            return Result : Outcome do
               TOML_Index.Load_Catalog
                 (Catalog_Dir => Directories.Parent
                                   (Repo_Version_Files.First_Element),
                  Environment => Env,
                  Result      => Result);
            end return;
         when others =>
            return Outcome_Failure ("Several index.toml files found in index");
      end case;
   end Load;

   -----------------
   -- New_Handler --
   -----------------

   function New_Handler (Origin : URL;
                         Name   : Restricted_Name;
                         Parent : Platform_Independent_Path)
                         return Invalid_Index is
      pragma Unreferenced (Origin, Name, Parent);
   begin
      return Idx : Invalid_Index (URL_Len => 0, Name_Len => 0, Dir_Len => 0);
   end New_Handler;

   -----------------
   -- New_Handler --
   -----------------

   function New_Handler (Origin : URL;
                         Name   : String;
                         Parent : Platform_Independent_Path;
                         Result : out Outcome) return Index'Class is
   begin
      if Name not in Restricted_Name then
         Result := Outcome_Failure ("Name is too short/long or contains"
                                    & " illegal characters");
         return Invalid_Index'(New_Handler (Origin, Name, Parent));
      end if;

      case VCSs.Kind (Origin) is
         when VCSs.VCS_Git =>
            Result := Outcome_Success;
            raise Unimplemented;
            return Index_On_Disk.Git.New_Handler (Origin, Name, Parent);
         when VCSs.VCS_Unknown =>
            Result := Outcome_Failure ("Unknown index kind: " & Origin);
            return Invalid_Index'(New_Handler (Origin, Name, Parent));
      end case;
   end New_Handler;

   -------------
   -- To_TOML --
   -------------

   function To_TOML (This : Index) return TOML.TOML_Value is
      Table : constant TOML.TOML_Value := TOML.Create_Table;
   begin
      Table.Set (TOML_Keys.Index_URL, TOML.Create_String (This.Origin));
      return Table;
   end To_TOML;

   ---------------
   -- Unique_Id --
   ---------------

   function Name (This : Index'Class) return Restricted_Name is
     (This.Name);

end Alire.Index_On_Disk;
