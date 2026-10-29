{ lib, ... }:

{
  options.me = lib.mkOption {
    type = lib.types.submodule {
      options = {
        username = lib.mkOption {
          type = lib.types.str;
        };
        fullname = lib.mkOption {
          type = lib.types.str;
        };
        email = lib.mkOption {
          type = lib.types.str;
        };
      };
    };
  };

  config.me = {
    username = "alex";
    fullname = "Alexander Chernoff";
    email = "chernoff.alex1@gmail.com";
  };
}
