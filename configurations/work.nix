{
  pkgs,
  openaws-vpn-client,
  nix-vscode-extensions,
}:

{
  packages = with pkgs; [
    keepassxc
    doppler
    redis
    sqlitebrowser
    kubectl
    k9s
    httptoolkit
    mongodb-compass
    go-task
    ngrok
    devenv
    dbeaver-bin
    openaws-vpn-client.defaultPackage.${pkgs.system}
    gh
    awscli2
    vault
  ];
}
