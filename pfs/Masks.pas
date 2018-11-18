{***************************************************************
 *
 * Unit Name : Masks
 * Purpose   : Pattern Mask object - Will identify strings of a
 *             particular pattern. Usefull for searching for
 *             particular filetypes amongst many other things.
 * Author    : J W Gregg, J@magic01.freeserve.co.uk - 1999
 * History   : V1.1 See corresponding footnotes for Use.
 * Copywright: John Gregg, 1999
 *
 * This Unit is a replacement for Borlands Masks unit which is
 * only available with the client server version. :(
 * It offers the Class TMask - which includes the method Match().
 *
 * This unit and it's contents are FreeWare, you may use them freely
 * commercialy or otherwise, however, I would like a full version
 * of the program in which it is used or partly used. You are Not
 * allowed though, to alter any of the code in this unit without
 * permission by me, J W Gregg, except the constant parameter named
 * MAXPARTS.
 *
 * Any bug reports or request etc, to me at the above email address.
 *
 ****************************************************************}

unit Masks;

interface

uses sysutils;

Const
   MAXPARTS = 15; {Change this as you wish, but be aware of mem issues.}

type
   EMaskError = class(Exception);
   status = (SUCCESS, FAILURE, EOF);
   TMask = class;
   func = function(part1, part2: string;
                   mask: TMask;
                   start: integer):status;

   TMask = class
     public
      substring: string;
      functionCall: array [1..MAXPARTS] of func;
      piece: array [1..MAXPARTS] of string;
      function Match(txt: string; start: integer): Boolean;
      constructor create(pattern: string);
   end;

   function isString(part1, part2: string;
                     mask: TMask;
                     start: integer):status;
   function notInSet(part1, part2: string;
                     mask: TMask;
                     start: integer):status;
   function inSet(part1, part2: string;
                  mask: TMask;
                  start: integer):status;
   function isNot(part1, part2: string;
                  mask: TMask;
                  start: integer):status;
   function isAny(part1, part2: string;
                  mask: TMask;
                  start: integer):status;
   function isAbs(part1, part2: string;
                  mask: TMask;
                  start: integer):status;
   function isAnyMultiple(part1, part2: string;
                          mask: TMask;
                          start: integer):status;
   function notOr(part1, part2: string;
                  mask: TMask;
                  start: integer):status;
   function isOr(part1, part2: string;
                 mask: TMask;
                 start: integer):status;
   function EOM(part1, part2: string;
                mask: TMask;
                start: integer):status;

implementation

constructor TMask.create(pattern: string);
var
   pos: integer;
   partNo: integer;
   pieceTxt: string;
   currentPos: integer;
   seperators: set of char;
   done: boolean;

begin
   done := False;
   pos := 1;
   partNo := 1;
   seperators := ['[','!','*','?','#','('];
   while not done do
   begin
      currentPos := pos;
      if partNo > MAXPARTS then
         raise EMaskError.create('Error');
      while not((pattern[pos] in seperators) or (pos = length(pattern))) do
         inc(pos);
      if pattern[pos] in seperators then
      begin
         if pos - currentPos >= 1 then
         begin
            functionCall[partNo] := @isString;
            piece[partNo] := copy(pattern, currentPos, pos - currentPos);
            currentPos := pos;
            inc(partNo);
         end;
         case pattern[pos] of
            '[': begin
                    repeat
                      inc(pos);
                    until (pattern[pos] = ']') or (pos >= length(pattern));
                    if pos > length(pattern) then
                       raise EMaskError.create('Error');
                    if pattern[pos] = ']' then
                    begin
                       pieceTxt := copy(pattern, currentPos, (pos - currentPos) + 1);
                       if pieceTxt[2] = '!' then
                       begin
                          if pieceTxt[4] = '-' then
                          begin
                              piece[partNo] := concat(pieceTxt[3],pieceTxt[5]);
                              functionCall[partNo] := @notInSet;
                          end
                          else
                              raise EMaskError.create('Error');
                       end
                       else
                       begin
                          if pieceTxt[3] = '-' then
                          begin
                              piece[partNo] := concat(pieceTxt[2],pieceTxt[4]);
                              functionCall[partNo] := @inSet;
                          end
                          else
                              raise EMaskError.create('Error');
                       end;
                    end
                    else
                      raise EMaskError.create('Error');
                    inc(pos);
                 end;
            '(': begin
                    repeat
                      inc(pos);
                    until (pattern[pos] = ')') or (pos >= length(pattern));
                    if pos > length(pattern) then
                       raise EMaskError.create('Error');
                    if pattern[pos] = ')' then
                    begin
                       pieceTxt := copy(pattern, currentPos, (pos - currentPos) + 1);
                       if pieceTxt[2] = '!' then
                       begin
                          piece[partNo] := copy(pieceTxt, 3, length(pieceTxt) - 3);
                          functionCall[partNo] := @notOr;
                       end
                       else
                       begin
                          piece[partNo] := copy(pieceTxt, 2, length(pieceTxt) - 2);
                          functionCall[partNo] := @isOr;
                       end
                    end
                    else
                      raise EMaskError.create('Error');
                    inc(pos);
                 end;
            '!': begin
                    inc(pos);
                    if pos > length(pattern) then
                       raise EMaskError.create('Error');
                    piece[partNo] := pattern[pos];
                    functionCall[partNo] := @isNot;
                    inc(pos);
                 end;
            '*': begin
                    piece[partNo] := '*';
                    functionCall[partNo] := @isAnyMultiple;
                    inc(pos);
                 end;
            '?': begin
                    piece[partNo] := '?';
                    functionCall[partNo] := @isAny;
                    inc(pos);
                 end;
            '#': begin
                    inc(pos);
                    if pos > length(pattern) then
                       raise EMaskError.create('Error');
                    piece[partNo] := pattern[pos];
                    functionCall[partNo] := @isAbs;
                    inc(pos);
                 end;
         end;
         inc(partNo);
      end
      else
      begin
         functionCall[partNo] := @isString;
         piece[partNo] := copy(pattern, currentPos, pos);
         inc(pos);
         inc(partNo);
      end;
      if Pos > length(pattern) then
      begin
         functionCall[partNo] := @EOM;
         done := True;
      end;
   end;
end;

function TMask.Match(txt: string; start: integer): Boolean;
var
   answer: status;

begin
   substring := txt;
   try
       answer := functionCall[start](piece[start], substring, self, start);
       if (answer = SUCCESS) and (@functionCall[start] = @isAnyMultiple) then
          answer := EOF;
       while (answer <> EOF) and (answer <> FAILURE) do
       begin
           inc(start);
           answer := functionCall[start](piece[start], substring, self, start);
           if (answer = SUCCESS) and (@functionCall[start] = @isAnyMultiple) then
              answer := EOF;
       end;
       if answer = EOF then
           Match := True
       else
           Match := False;
   except
       Match := False;
   end
end;

function isString(part1, part2: string;
                  mask: TMask;
                  start: integer): status;
var
   x: integer;
   notValid: Boolean;

begin
   x := 1;
   notValid := False;
   while (x <= length(part1)) and not(notValid) do
   begin
      if compareStr(part1[x], part2[x]) <> 0 then
         notValid := True;
      inc(x);
   end;
   if notValid then
      isString := FAILURE
   else
   begin
      mask.substring := copy(part2, x, length(part2));
      isString := SUCCESS;
   end;
end;

function notInSet(part1, part2: string;
                  mask: TMask;
                  start: integer): status;
var
   s: set of char;

begin
   s := [part1[1]..part1[2]];
   if part2[1] in s then
      notInSet := FAILURE
   else
   begin
      mask.substring := copy(part2, 2, length(part2));
      notInSet := SUCCESS;
   end
end;

function inSet(part1, part2: string;
               mask: TMask;
               start: integer): status;
var
   s: set of char;

begin
   s := [part1[1]..part1[2]];
   if part2[1] in s then
   begin
      mask.substring := copy(part2, 2, length(part2));
      inSet := SUCCESS;
   end
   else
      inSet := FAILURE;
end;

function notOr(part1, part2: string;
               mask: TMask;
               start: integer):status;
var
   s: set of char;
   x: integer;

begin
   for x := 1 to length(part1) do
      s := s + [part1[x]];
   if part2[1] in s then
      notOr := FAILURE
   else
   begin
      mask.substring := copy(part2, 2, length(part2));
      notOr := SUCCESS;
   end
end;

function isOr(part1, part2: string;
              mask: TMask;
              start: integer):status;
var
   s: set of char;
   x: integer;

begin
   s := [];
   for x := 1 to length(part1) do
      s := s + [part1[x]];
   if part2[1] in s then
   begin
      mask.substring := copy(part2, 2, length(part2));
      isOr := SUCCESS;
   end
   else
      isOr := FAILURE;
end;

function isNot(part1, part2: string;
               mask: TMask;
               start: integer): status;
begin
   if compareStr(part1[1], part2[1]) = 0 then
      isNot := FAILURE
   else
   begin
      mask.substring := copy(part2, 2, length(part2));
      isNot := SUCCESS;
   end
end;

function isAny(part1, part2: string;
               mask: TMask;
               start: integer): status;
begin
   mask.substring := copy(part2, 2, length(part1));
   isAny := SUCCESS;
end;

function isAbs(part1, part2: string;
               mask: TMask;
               start: integer): status;
begin
   if compareStr(part1[1], part2[1]) = 0 then
   begin
      mask.substring := copy(part2, 2, length(part2));
      isAbs := SUCCESS;
   end
   else
      isAbs := FAILURE;
end;

function isAnyMultiple(part1, part2: string;
                       mask: TMask;
                       start: integer): status;
var
   x, y: integer;
   answer: Boolean;

begin
   x := 1;
   y := length(part2);
   repeat
      answer := mask.Match(part2, start + 1);
      if not answer then
         part2 := copy(part2, 2, y);
      inc(x);
   until (answer = TRUE) or (x > y);
   if answer then
   begin
      mask.substring := part2;
      isAnyMultiple := SUCCESS;
   end
   else
      isAnyMultiple := FAILURE;
end;

function EOM(part1, part2: string;
             mask: TMask;
             start: integer): status;
begin
   EOM := EOF;
end;

end.

{V1.01 - 17th March 1999 *******************************************************

 Several parsing bugs removed, seems to be ok now.

 Bug 1: wouldnt interpret correctly ---> *(1234).doc
 Bug 2: couldnt construct ---> *.[a-b](12345)_*

 ******************************************************************************}
{V1.0 - 11th March 1999 ********************************************************

 Create the object using the constructor: Create( pattern: String);

 When used it will identify certain strings using the following criteria
 functions:

 1. The number of fuctions within the Pattern Match string passed to the
    constructer must be less than or equal to MAXPARTS (15). For all intents and
    purposes this is all I require at this time, however I'm to include a more
    dynamic allocation structure in later versions, or can in the interim
    increase the value on request.
 2. The Object handles several types of criteria functions within a string,
    these are listed as follows, each with a brief description.

    Sets - These are constructed within the string using the '[' character. When
           the parser finds a matching ']' it will proceed to
           analyse the information. If no matching ']' is found, then an
           exception is raised. Valid examples are:-

           [a-b] - Is within the range 'a' to 'b'. --> (a, b)
           [v-z] - Is within the range 'v' to 'z'. --> (v, w, x, y, z)
           [!b-z] - Is NOT within the range 'b' to 'z'. -->
                                           (All chars except 'b'..'z' inclusive)
           Note the use of '!' here which logically NOT's the arguments.
           The construct must be exactly as shown, and is valid for 1 character
           only in the string to be matched. Bad examples follow:-

           ![a-b]
           [a-b!]
           [ab].

    OR's - These are constructed within the string using the '(' character. If
           no matching ')' is found then an exception is raised. Valid examples
           follow:-

           (ab) - Is 'a' or 'b'. --> (a, b)
           (abcdef) - Is 'a', 'b'...'f'. --> (a, b, c, d, e, f)
           (!ab) - Is NOT 'a' or 'b'.

           The construct rules for Sets generally apply, except here, the parser
           would not appreciate the following constructs:-

           (a)
           (!a)

           In either case it would interpret the construct as 'a' or ')', in
           other words a second character should be explicitly declared within
           the string so that the OR is carried out correctly.

    * -    You can use this to define a list of any characters, of any length,
           including the empty character ''. This is a standard pattern match
           operator on most systems, and behaves exactly the same here.

    ? -    This is straight forward and just means any character. Note this
           does not include the empty character.

    ! -    Use this alongside any character and it means NOT that character.
           Valid uses follow:-

           !a
           !z

           Note a character must follow the operater, or an exception will
           occur. Invalid expressions follow:-

           !
           ![a-b]
           !(ab).

    # -    This character allows you to explicitly define other operators,
           including itself, as ordinary characters. Valid ops follow:-

           #[
           #!
           ##.

           Here a character should be explicitly delared after this operator,
           or you could get silly results.

    Literal strings can be iserted as is, and are matched identically.

    Note: all operations on matching are case sensitive.

 When you create the object any errors in the pattern string you pass with the
 constructor should be found and an exception will occur, In this case, it is
 wise then to use try - except blocks unless you are absolutely sure.

 Once constructed then, there are two things you can do with this object:-

 1. Match the pattern with another string: Use the method
            function Match(txt: string, 1): Boolean
    Where a boolean is returned indicating whether the string matched the
    pattern String, which was passed to the constructor, or not.
    Always Use the value 1 for the second parameter.

 2. Call the method Free to release the object.

 Note this Object is fast since half the work is done on construction
 of the object. It doesnt use stack intensive recursion either.

 Some valid examples:

 1. [a-c]!a(abcdef)*.txt
    match = cockie.txt, bed.txt etc
    not match = cac.txt etc.

 2. *.*

 ******************************************************************************}

