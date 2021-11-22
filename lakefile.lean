import Lake
open Lake DSL System

def tag : String := "nightly-2021-11-17"
def releaseRepo : String := "leanprover-community/mathport"
def oleanTarName : String := "lean3-binport.tar.gz"
def leanTarName : String := "lean3-synport.tar.gz"

def download (url : String) (to : FilePath) : BuildM PUnit := Lake.proc
{ -- We use `curl -O` to ensure we clobber any existing file.
  cmd := "curl",
  args := #["-L", "-O", url]
  cwd := to }

def untar (file : FilePath) : BuildM PUnit := Lake.proc
{ cmd := "tar",
  args := #["-xzvf", file.fileName.getD "."] -- really should throw an error if `file.fileName = none`
  cwd := file.parent }

def getReleaseArtifact (repo tag artifact : String) (to : FilePath) : BuildM PUnit :=
download s!"https://github.com/{repo}/releases/download/{tag}/{artifact}" to

def untarReleaseArtifact (repo tag artifact : String) (to : FilePath) : BuildM PUnit := do
  getReleaseArtifact repo tag artifact to
  untar (to / artifact)

def fetchOleans (dir : FilePath) : OpaqueTarget := { info := (), task := fetch } where
  fetch := async do
    IO.FS.createDirAll libDir
    let oldTrace := Hash.ofString (← Git.headRevision dir)
    buildFileUnlessUpToDate (libDir / oleanTarName) oldTrace do
      untarReleaseArtifact releaseRepo tag oleanTarName libDir

  libDir : FilePath := dir / "build" / "lib"

def fetchLeans (dir : FilePath) : OpaqueTarget := { info := (), task := fetch } where
  fetch := async do
    IO.FS.createDirAll srcDir
    let oldTrace := Hash.ofString (← Git.headRevision dir)
    buildFileUnlessUpToDate (srcDir / leanTarName) oldTrace do
      untarReleaseArtifact releaseRepo tag leanTarName srcDir

  srcDir : FilePath := dir

package lean3port (dir) {
  libRoots := #[]
  libGlobs := #[`Leanbin]
  extraDepTarget := Target.collectOpaqueList [fetchLeans dir, fetchOleans dir]
  defaultFacet := PackageFacet.oleans
  dependencies := #[{
    name := "mathlib",
    src := Source.git "https://github.com/leanprover-community/mathlib4.git" "64f9c43eb9a75fb4c5989ac711623d06e9696e60"
  }]
}