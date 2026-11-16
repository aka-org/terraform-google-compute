# Changelog
All notable changes to this project will be documented in this file.

## 0.5.0
### CHANGED
- The Google provider constraint is a range, `>= 6.23, < 8` (was exactly `6.8.0`); validated on 6.23.0 and 7.46.2. 6.23.0 is the first release with write-only secret values.
- **Breaking for callers passing `secret_values`:** secret values are no longer stored in Terraform state. `secret_values` is an ephemeral variable and versions are written through `secret_data_wo`. Pass the values from an ephemeral variable at plan and at apply; existing versions are replaced once on upgrade (same value, new version); a later value change needs the secret's `value_version` raised. See the README's "Secrets", also for the values older state files still hold.
### ADDED
- `secrets[].value_version` (default 1).
- The `random` provider is declared in `required_providers`; every submodule declares the providers it uses.
- CI: `terraform fmt`, `validate` on the lowest and newest supported provider, TFLint.
- README: "Secrets" and "Development".
### FIXED
- `secrets` defaults to `[]`, as documented (it was required).
- README: the `secrets` variable's name and the usage example.

## 0.4.0
### ADDED
- Add optional secret creation.

## 0.3.0
### ADDED
- Ignore changes to ip alias ranges of primary network interface.

## 0.2.0
### CHANGED
- VM service account id now contains a random suffix.

## 0.1.0
### ADDED
- Initial release of the terraform-google-compute module.
