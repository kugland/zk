import unittest

from common import run

class TestZle(unittest.TestCase):
    def test_zle(self):
      """Test basic cursor movement"""
      hi = run("""
               !\033[Dhi\033[C\033C' 'how are you'\033[Hecho '\033[F'?'
               !\033ODhi\033OC\033C' 'how are you'\033OHecho '\033OF'?'
               """,
               preamble="source ./zle/zk_zle.plugin.zsh")
      self.assertEqual(hi, "hi! how are you?\n" * 2)


if __name__ == "__main__":
    #unittest.main()
    hi = run("""
              !\033[Dhi\033[C\033C' 'how are you'\033[Hecho '\033[F'?'
              !\033ODhi\033OC\033C' 'how are you'\033OHecho '\033OF'?'
              """,
              preamble="source ./zle/zk_zle.plugin.zsh",
              sidechannel=False,
              term="dumb")
    print(hi)
