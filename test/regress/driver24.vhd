-- A process driving a signal only through a signal parameter of an
-- impure function (allowed in VHDL-2019) must still have a driver for
-- it.  Previously only procedure calls were considered and the first
-- assignment crashed.

package driver24_pkg is
  type rec is record
    x, y : bit;
  end record;

  view rec_out of rec is
    x : out;
    y : in;
  end view;

  impure function drive (signal s : out bit) return boolean;

  impure function drive_view (signal r : view rec_out) return boolean;

  impure function drive_generic
    generic (v : bit)
    parameter (signal s : out bit) return boolean;
end package;

package body driver24_pkg is
  impure function drive (signal s : out bit) return boolean is
  begin
    s <= '1';
    return true;
  end function;

  impure function drive_view (signal r : view rec_out) return boolean is
  begin
    r.x <= '1';
    return true;
  end function;

  impure function drive_generic
    generic (v : bit)
    parameter (signal s : out bit) return boolean is
  begin
    s <= v;
    return true;
  end function;
end package body;

-------------------------------------------------------------------------------

use work.driver24_pkg.all;

entity driver24 is
end entity;

architecture test of driver24 is
  signal s1, s2 : bit;
  signal r      : rec;

  function inst is new drive_generic generic map (v => '1');
begin

  p1 : process is
  begin
    wait for 1 ns;
    assert drive(s1);
    wait;
  end process;

  p2 : process is
  begin
    wait for 1 ns;
    assert drive_view(r);
    wait;
  end process;

  p3 : process is
  begin
    wait for 1 ns;
    assert inst(s2);
    wait;
  end process;

  check : process is
  begin
    wait for 2 ns;
    assert s1 = '1';
    assert r.x = '1';
    assert s2 = '1';
    report "PASSED";
    wait;
  end process;

end architecture;
