# PSScriptAnalyzer settings for this repository.
#
# One ruleset, three consumers, so the editor, the commit hook and CI agree:
#   - Neovim        lua/plugin/powershell.lua → PowerShell Editor Services
#   - pre-commit    scripts/hooks/check-ps1.ps1
#   - CI            the `powershell` lane of ./scripts/check.sh, via the same hook
#
# It lives beside the style-configs rather than in dot_config/powershell/
# because that directory is Windows-only (.chezmoiignore), while Neovim needs
# this file on every platform. Unlike its neighbours here it is not a template
# to copy into another project — it is what this repository lints with.
@{
  # Only the severity levels worth acting on. This hides informational
  # messages such as the OutputType hints.
  Severity = @(
    'Error'
    'Warning'
  )

  # Deliberately only the rules that pay for themselves day to day.
  IncludeRules = @(
    'PSAvoidUsingCmdletAliases'
    'PSUseCorrectCasing'
    'PSAvoidTrailingWhitespace'
    'PSUseDeclaredVarsMoreThanAssignments'
    'PSAvoidUsingPlainTextForPassword'
    'PSAvoidUsingConvertToSecureStringWithPlainText'
  )

  # Rules that add more noise than value in the Neovim diagnostics window.
  ExcludeRules = @(
    # Formatting is the formatter's job, not the LSP's.
    'PSUseConsistentIndentation'
    'PSUseConsistentWhitespace'
    'PSPlaceOpenBrace'
    'PSPlaceCloseBrace'
    'PSAlignAssignmentStatement'
    'PSUseConsistentFormatting'

    # Too loud for small local scripts.
    'PSUseOutputTypeCorrectly'
    'PSAvoidUsingWriteHost'

    # Only useful with concrete target platforms maintained properly.
    'PSUseCompatibleCmdlets'
  )

  Rules = @{
    # Cmdlets spelled correctly, e.g. Get-ChildItem rather than get-childitem.
    PSUseCorrectCasing = @{
      Enable = $true
    }

    # No aliases such as gci, ls, %, ?.
    PSAvoidUsingCmdletAliases = @{
      Enable = $true
    }

    # Catch unused variables.
    PSUseDeclaredVarsMoreThanAssignments = @{
      Enable = $true
    }

    # Catch trailing whitespace.
    PSAvoidTrailingWhitespace = @{
      Enable = $true
    }

    # Security-relevant checks.
    PSAvoidUsingPlainTextForPassword = @{
      Enable = $true
    }

    PSAvoidUsingConvertToSecureStringWithPlainText = @{
      Enable = $true
    }
  }
}
