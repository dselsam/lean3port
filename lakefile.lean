import Lake
open Lake DSL System

def tag : String := "nightly-2021-11-17"
def releaseRepo : String := "leanprover-community/mathport"
def tarName : String := "lean3-binport.tar.gz"

def fetchOleans (dir : FilePath) : OpaqueTarget := { info := (), task := fetch } where
  fetch := async do
    IO.FS.createDirAll libDir
    let oldTrace := Hash.ofString (← Git.headRevision dir)
    buildFileUnlessUpToDate (libDir / tarName) oldTrace do
      downloadOleans
      untarOleans

  downloadOleans : BuildM PUnit := Lake.proc {
      cmd := "wget",
      args := #[s!"https://github.com/{releaseRepo}/releases/download/{tag}/{tarName}"]
      cwd := libDir.toString
    }

  untarOleans : BuildM PUnit := Lake.proc {
      cmd := "tar",
      args := #["-xzvf", tarName]
      cwd := libDir.toString
    }

  libDir : FilePath := dir / "build" / "lib"

package lean3port (dir) {
  libRoots := #[]
  libGlobs := #[`Leanbin]
  extraDepTarget := fetchOleans dir
  defaultFacet := PackageFacet.oleans
  dependencies := #[{
    name := "mathlib",
    src := Source.git "https://github.com/leanprover-community/mathlib4.git" "64f9c43eb9a75fb4c5989ac711623d06e9696e60"
  }]
}
