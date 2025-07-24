# d365-spkl-webresources-automation

Automation script for maintaining the `spkl.json` webresources section in Dynamics 365 / Power Platform projects.

This repository contains a PowerShell script that updates the `spkl.json` configuration file for [spkl](https://github.com/scottdurow/spkl) deployments. It scans your git diff for changed TypeScript files and updates the `"files"` section in `spkl.json` to include only the JavaScript webresources that need to be deployed.  
Perfect for teams and CI/CD pipelines working with large solutions or TypeScript-first projects.

---

## Features

- **Automatic mapping:** Updates the `spkl.json` `"files"` section based on recent `.ts` file changes detected in git (staged, unstaged, and recent commits).
- **Flexible naming conventions:** Easy to adjust resource prefix, folder structure, and minified output mode.
- **Prevents accidental deploy:** If no relevant changes are found, the script clears the `"files"` array to avoid pushing stale or unwanted files.
- **Bundled helpers:** Supports custom mapping for merged/bundled files (e.g. `helper-metadata.js`).
- **No CRM credentials required:** Pure config and automation-safe for public use.

---

## How It Works

1. **Run the script in your project directory:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\update-spkl-json-from-git.ps1 -Root js [-UseMinified]
    ```
  - Root js - subfolder where JS files are built (relative to repo root).
  - UseMinified - optional flag; if set, generates mapping for .min.js files instead of .js.

2. The script:
  - Looks for changed .ts files (using git diff and git log).
  - Maps each to the corresponding JS or minified JS file.
  - Applies naming conventions (e.g. prefix xyz_).
  - Updates only the "files" section of your spkl.json.

3. Deploy using spkl:
   ```spkl.exe webresources```

### Example spkl.json
```json
{
  "webresources": [
    {
      "profile": "default,debug",
      "root": "js",
      "solution": "DEMO_SOLUTION",
      "files": [
        {
          "type": 3,
          "uniquename": "xyz_demo.contact.form",
          "file": "entities/contact/contact.form.js",
          "publish": true
        },
        {
          "type": 3,
          "uniquename": "xyz_demo.opportunity.grid",
          "file": "entities/opportunity/opportunity.grid.js",
          "publish": true
        },
        {
          "type": 3,
          "uniquename": "xyz_demo.account.helper",
          "file": "utilities/account-helper.js",
          "publish": true
        }
      ]
    }
  ]
}
```
No comments, no trailing commas - must be pure JSON!

### Requirements

```
PowerShell 5+ (Windows)
git (available in PATH)
spkl installed as a NuGet package in your solution
Project structure with a clear JS root and spkl.json present
```

### Customization

  - Adjust naming conventions (e.g. prefix), folder structure, or mapping logic at the top of the script for your repo needs.
  - Extend the script to support CSS, HTML, or other resource types as needed.

### Disclaimer

This repository contains automation only - no credentials, no connection strings, and no customer data.

Open source, MIT License.
