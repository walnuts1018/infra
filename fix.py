import os
import re
import subprocess

def process_file(filepath):
    if not filepath.endswith('.jsonnet') and not filepath.endswith('.libsonnet'):
        return
    
    with open(filepath, 'r') as f:
        content = f.read()

    # Find declarations: local varName = import '...'; or local varName = importstr '...';
    # We will use regex to find them.
    # Note: sometimes it's local varName = (import '...');
    # Let's match: local\s+([a-zA-Z0-9_]+)\s*=\s*(import(str)?\s+['"][^'"]+['"]|\(import(str)?\s+['"][^'"]+['"]\));
    
    pattern = re.compile(r"^local\s+([a-zA-Z0-9_]+)\s*=\s*(importstr\s+['\"][^'\"]+['\"]|import\s+['\"][^'\"]+['\"]|\(importstr\s+['\"][^'\"]+['\"]\)|\(import\s+['\"][^'\"]+['\"]\));$", re.MULTILINE)
    
    matches = list(pattern.finditer(content))
    
    # Process from bottom to top so replacements don't mess up offsets
    # Wait, doing it iteratively is safer.
    
    changed = False
    for _ in range(10): # retry loop in case of multiple
        matches = list(pattern.finditer(content))
        if not matches:
            break
            
        made_change_in_iteration = False
        for match in matches:
            var_name = match.group(1)
            expr = match.group(2)
            decl_line = match.group(0)
            
            # Count usages of var_name in the whole file
            # excluding the declaration line
            
            # Replace declaration line with empty string
            temp_content = content[:match.start()] + content[match.end():]
            
            # Find usages
            usage_pattern = re.compile(r'\b' + re.escape(var_name) + r'\b')
            usages = list(usage_pattern.finditer(temp_content))
            
            if len(usages) == 1:
                # Used exactly once. Inline it.
                # If usage is `(var)`, we could replace `var` with `expr`.
                # Wait, better to replace `var` with `(expr)` to be safe, but let's check if expr already has parens.
                if not expr.startswith('('):
                    replacement = f"({expr})"
                else:
                    replacement = expr
                
                # We need to replace the exact usage.
                u = usages[0]
                temp_content = temp_content[:u.start()] + replacement + temp_content[u.end():]
                
                # Now remove the newline left by the declaration if it leaves an empty line
                temp_content = temp_content.replace('\n\n', '\n')
                
                content = temp_content
                changed = True
                made_change_in_iteration = True
                break # break to re-evaluate matches
                
        if not made_change_in_iteration:
            break

    if changed:
        # cleanup double newlines at start
        content = content.lstrip('\n')
        with open(filepath, 'w') as f:
            f.write(content)

# get files changed in PR
try:
    files = subprocess.check_output(['git', 'diff', '--name-only', 'origin/main']).decode('utf-8').splitlines()
    for f in files:
        if os.path.exists(f):
            process_file(f)
except Exception as e:
    print(e)
