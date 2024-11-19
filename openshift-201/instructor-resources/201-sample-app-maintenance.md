# 201 Sample App Maintenance

This doc only covers the following sample applications so far:
- [myapp for Image Management](../materials/image-management/sample-app-nodejs/)
- [crash app for Post Outage Checkup](../materials/post-outage-checkup/crash-app-nodejs/)

## for a nodejs app:
```bash
# Step 0: Identify vulnerabilities to a specific application

# Step 1: Audit the npm packages to identify vulnerabilities
npm audit

# Step 2: Automatically fix vulnerabilities (non-breaking updates)
npm audit fix

# Step 3: Check outdated packages for manual updates
npm outdated

# Step 4: Update NPM packages
npm update

# OR: Update a specific package to a specific version
npm update <NPM_PACKAGE_NAME>@<VERSION>

# Step 5: Re-run the audit to ensure no vulnerabilities remain
npm audit

# Step 6: Clean and rebuild the project
rm -rf node_modules package-lock.json
npm install

# Finally: Test the application to verify everything works after updates
node index.js
```
