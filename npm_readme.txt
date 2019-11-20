1. install NPM (https://www.npmjs.com/get-npm)
2. generate a token in GitHub :
   - https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line
   - https://help.github.com/en/github/managing-packages-with-github-packages/about-github-packages#about-tokens
3. login with NPM using your token :
   $ npm login --registry=https://npm.pkg.github.com
   > Username: USERNAME (e.g. "davidp27")
   > Password: TOKEN (e.g. "3695fad767f87cf776f38555cc3bf9e7e84aef29")
   > Email: PUBLIC-EMAIL-ADDRESS (e.g. "toto@gmail.com")
4. before publishing changes to the scripts, update the VEAF scripts package :
   - edit the .\src\scripts\veaf\package.json file to change the version number
   - commit everything
   - push your changes
5. publish the newly changed package to GitHub Packages :
  $ publish.cmd
  
 