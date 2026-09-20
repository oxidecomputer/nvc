-- Test that a port reference inside a non-static port actual (LRM 6.5.6.3)
-- denotes the port of the block containing the instantiation and not the
-- port of the instantiated block.  These are distinct signals but share the
-- same declaration when an entity instantiates itself, and the equivalent
-- process is lowered in the scope of the instantiated block.

library ieee;
use ieee.std_logic_1164.all;

entity issue1662_blk is
  port (
    expr   : in std_logic;
    sig    : in std_logic;
    expect : in std_logic
  );
end entity;

architecture child of issue1662_blk is
begin
  check : process is
  begin
    wait for 1 ns;
    assert expr = expect
      report "expected " & to_string(expect) & " but got " & to_string(expr)
      severity failure;
    wait;
  end process;
end architecture;

-------------------------------------------------------------------------------

-- Identical to issue1662_blk apart from the name: used as a control as the
-- ports of a different entity cannot capture the reference

library ieee;
use ieee.std_logic_1164.all;

entity issue1662_clone is
  port (
    expr   : in std_logic;
    sig    : in std_logic;
    expect : in std_logic
  );
end entity;

architecture child of issue1662_clone is
begin
  check : process is
  begin
    wait for 1 ns;
    assert expr = expect
      report "expected " & to_string(expect) & " but got " & to_string(expr)
      severity failure;
    wait;
  end process;
end architecture;

-------------------------------------------------------------------------------

architecture top of issue1662_blk is
begin
  -- The SIG port of this block is driven to '1' while each instance below
  -- associates its own SIG port with '0'.  The actual for EXPR denotes the
  -- port of this block so every instance must see '1'.

  self : entity work.issue1662_blk(child)
    port map ( expr => sig and '1', sig => '0', expect => '1' );

  clone : entity work.issue1662_clone(child)
    port map ( expr => sig and '1', sig => '0', expect => '1' );

  -- Here the captured reference would be the port being driven, leaving it
  -- at 'U' for the whole simulation

  selfref : entity work.issue1662_blk(child)
    port map ( expr => expr and not expr, sig => '0', expect => '0' );
end architecture;

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity issue1662 is
end entity;

architecture test of issue1662 is
  signal one : std_logic := '1';
begin
  uut : entity work.issue1662_blk(top)
    port map ( expr => '0', sig => one, expect => '0' );

  process is
  begin
    wait for 10 ns;
    report "PASSED";
    wait;
  end process;
end architecture;
