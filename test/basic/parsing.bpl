
var $glob: int;

procedure {:some_attr} some_proc(x: int)
requires true;
ensures true;
modifies $glob;
{
  if (*) {
    $glob := 0;
  } else {
    $glob := 1;
  }
  return;
}
