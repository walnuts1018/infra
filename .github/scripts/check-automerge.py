import subprocess
import re
import os

automerge = False
old_major = old_minor = old_patch = new_major = new_minor = new_patch = None

result = subprocess.run("gh pr diff", shell=True, capture_output=True)
if result.returncode == 0:
    diff = result.stdout.decode("utf-8")
    if match := re.search(r"\-.+?(\d+)\.(\d+)\.(\d+).+\"\$imagepolicy\"", diff):
        old_major, old_minor, old_patch = match.groups()
        
    if match := re.search(r"\+.+?(\d+)\.(\d+)\.(\d+).+\"\$imagepolicy\"", diff):
        new_major, new_minor, new_patch = match.groups()

    if new_major == old_major and new_minor == old_minor:
        automerge = True

with open(os.environ["GITHUB_OUTPUT"], "a") as f :
    print("Automerge: %s" % automerge)
    print("{0}={1}".format("automerge", automerge), file=f)
    print("Old tag: %s.%s.%s" % (old_major, old_minor, old_patch))
    print("{0}={1}".format("old_tag", "%s.%s.%s" % (old_major, old_minor, old_patch)), file=f)
    print("New tag: %s.%s.%s" % (new_major, new_minor, new_patch))
    print("{0}={1}".format("new_tag", "%s.%s.%s" % (new_major, new_minor, new_patch)), file=f)
