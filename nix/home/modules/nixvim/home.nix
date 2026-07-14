{ lib, pkgs, ... }:

let
	mkRaw = lib.generators.mkLuaInline;
in
{
	programs.nixvim = { config, ... }: {
		enable = true;

		extraPackages = with pkgs; [
			alejandra
			fd
			markdownlint-cli2
			ripgrep
			stylua
			xdg-utils
		];

		# clipboard shared between os and nvim.
		# might try scheduling for after ui enter to improve startup time?
		clipboard = {
			register = "unnamedplus";
			providers.wl-copy.enable = true;
		};

		globals = {
			mapleader = " ";
			maplocalleader = " ";

			# disable warnings
			loaded_perl_provider = 0;
			loaded_ruby_provider = 0;
			loaded_python3_provider = 0;
		};

		highlightOverride = {
			Normal.bg = "NONE";
			NormalNC.bg = "NONE";
			SignColumn.bg = "NONE";
			EndOfBuffer.bg = "NONE";
		};

		opts = {
			number = true;
			relativenumber = true;
			tabstop = 2;
			shiftwidth = 2;

			showmode = false;
			breakindent = true;

			undofile = true;
			
			# case-insensitive searching unless \C or capital letters in the search
			ignorecase = true;
			smartcase = true;

			# keeps the sign column always on
			signcolumn = "yes";

			updatetime = 250;
			timeoutlen = 300;

      list = true;
			listchars = { tab = "» "; trail = "·"; nbsp = "␣"; };

			# preview substitutions live
			inccommand = "split";
			
			# show which line cursor is on
			cursorline = true;
			scrolloff = 10;

			# confirm save on :q, etc...
			confirm = true;

			# so not everything is folded from the start
			foldlevel = 99;
			foldlevelstart = 99;
		};

		diagnostic.settings = {
			update_in_insert = false;
			severity_sort = true;
			float = { 
				border = "rounded";
				source = "if_many";
			};
			underline.severity.min = mkRaw "vim.diagnostic.severity.WARN";

			virtual_text = true; # text shows up at the end of the line
			virtual_lines = false; # text shows up underneath the line in virtual lines

			jump.on_jump = mkRaw ''
				function(_, bufnr)
					vim.diagnostic.open_float {
						bufnr = bufnr,
						scope = 'cursor',
						focus = false,
					}
				end
			'';
		};

		autoGroups = {
			highlight-yank.clear = true;
		};

		autoCmd = [
			{
				event = "TextYankPost";
				group = "highlight-yank";
				callback = mkRaw "function() vim.hl.on_yank() end";
				desc = "Highlight when yanking (copying) text";
			}
		];

		keymaps = [
			{
				options.desc = "open diagnostic [q]uickfix list";
				mode = "n";
				key = "<leader>q";
				action = mkRaw "vim.diagnostic.setloclist";
			}
			{
				# clears highlights
				mode = "n";
				key = "<Esc>";
				action = "<cmd>nohlsearch<CR>";
			}

			# move lines up and down
		  { mode = "n"; key = "<A-Down>"; action = ":m .+1<CR>==";        options.silent = true; }
		  { mode = "n"; key = "<A-Up>";   action = ":m .-2<CR>==";        options.silent = true; }
		  { mode = "v"; key = "<A-Down>"; action = ":m >+1<CR>gv=gv";     options.silent = true; }
		  { mode = "v"; key = "<A-Up>";   action = ":m <-2<CR>gv=gv";     options.silent = true; }
		  { mode = "i"; key = "<A-Down>"; action = "<Esc>:m .+1<CR>==gi"; options.silent = true; }
		  { mode = "i"; key = "<A-Up>";   action = "<Esc>:m .-2<CR>==gi"; options.silent = true; }

			{
				mode = "n";
				key = "\\";
				action = "<Cmd>Neotree reveal<CR>";
				options = {
					desc = "NeoTree Reveal";
					silent = true;
				};
			}

			# formatting
			{
				key = "<leader>f";
				mode = ["n" "v"];
				action = mkRaw ''
					function()
						require('conform').format { async = true }
					end
				'';
				options.desc = "[f]ormat buffer";
			}

			# flash to not conflict
			{
				key = "s";
				mode = ["n" "x" "o"];
				action = mkRaw "require('flash').jump";
				options.desc = "Flash";
			}
			{
				key = "S";
				mode = ["n" "x" "o"];
				action = mkRaw "require('flash').treesitter";
				options.desc = "Flash Treesitter";
			}
			{
				key = "r";
				mode = "o";
				action = mkRaw "require('flash').remote";
				options.desc = "Remote Flash";
			}
			{
				key = "R";
				mode = ["o" "x"];
				action = mkRaw "require('flash').treesitter_search";
				options.desc = "Treesitter Search";
			}
			{
				key = "<c-s>";
				mode = "c";
				action = mkRaw "require('flash').toggle";
				options.desc = "Toggle Flash Search";
			}

			# dap
			{
				key = "<F5>";
				mode = "n";
				action = mkRaw "require('dap').continue";
				options.desc = "Debug: Start/Continue";
			}
			{
				key = "<F1>";
				mode = "n";
				action = mkRaw "require('dap').step_into";
				options.desc = "Debug: Step Into";
			}
			{
				key = "<F2>";
				mode = "n";
				action = mkRaw "require('dap').step_over";
				options.desc = "Debug: Step Over";
			}
			{
				key = "<F3>";
				mode = "n";
				action = mkRaw "require('dap').step_out";
				options.desc = "Debug: Step Out";
			}
			{
				key = "<leader>b";
				mode = "n";
				action = mkRaw "require('dap').toggle_breakpoint";
				options.desc = "Debug: Toggle Breakpoint";
			}
			{
				key = "<F7>";
				mode = "n";
				action = mkRaw "require('dapui').toggle";
				options.desc = "Debug: Toggle UI";
			}
		];

		plugins = {
			# Tools, Navigation, and Editing
			# ------------------------------
			flash.enable = true; # jump around
			gitsigns.enable = true;
			guess-indent.enable = true;
			image.enable = true;
			indent-blankline.enable = true;
			nvim-autopairs.enable = true;
			todo-comments.enable = true;
			tmux-navigator.enable = true;
			web-devicons.enable = true; 
			
			mini = {
				enable = true;

				modules = {
					ai = {
						n_lines = 500;
						mappings = {
							around_next = "aa";
							inside_next = "ii";
						};
					};
					icons = {};
					statusline = {};
					surround = {};
				};
			};

			neo-tree = {
				enable = true;

				settings = {
					clipboard.sync = "global";
					close_if_last_window = true;
					filesystem.window.mappings."\\" = "close_window";
				};
			};

			telescope = {
				enable = true;

				extensions = {
					ui-select.enable = true;
					fzf-native.enable = true;
				};

				keymaps = {
					"<leader>sh" =       { action = "help_tags";                     options.desc = "[s]earch [h]elp"; };
					"<leader>sk" =       { action = "keymaps";                       options.desc = "[s]earch [k]eymaps"; };
					"<leader>sf" =       { action = "find_files";                    options.desc = "[s]earch [f]iles"; };
					"<leader>ss" =       { action = "builtin";                       options.desc = "[s]earch [s]elect telescope"; };
					"<leader>sw" =       { action = "grep_string"; mode = ["n" "v"]; options.desc = "[s]earch current [w]ord"; };
					"<leader>sg" =       { action = "live_grep";                     options.desc = "[s]earch by [g]rep"; };
					"<leader>sd" =       { action = "diagnostics";                   options.desc = "[s]earch [d]iagnostics"; };
					"<leader>sr" =       { action = "resume";                        options.desc = "[s]earch [r]esume"; };
					"<leader>s." =       { action = "oldfiles";                      options.desc = "[s]earch recent files (. for repreat)"; };
					"<leader>sc" =       { action = "commands";                      options.desc = "[s]earch [c]commands"; };
					"<leader><leader>" = { action = "buffers";                       options.desc = "[ ] Find existing buffers"; };
					"grr" =              { action = "lsp_references";                options.desc = "[r]eferences"; };
					"gri" =              { action = "lsp_implementations";           options.desc = "[i]implementation"; };
					"grd" =              { action = "lsp_definitions";               options.desc ="[d]efinition"; };
					"grt" =              { action = "lsp_type_definitions";          options.desc = "[t]ype definition"; };
					"gO" =               { action = "lsp_document_symbols";          options.desc = "d[O]cument symbols"; };
					"gW" =               { action = "lsp_dynamic_workspace_symbols"; options.desc = "[W]orkspace symbols"; };
				};
			};
			
			which-key = {
				enable = true;

				settings = {
					spec = [
						{ 
							__unkeyed-1 = "<leader>s";
							group = "[s]earch";
							mode = ["n" "v"];
						}
						{
							__unkeyed-1 = "<leader>t";
							group = "[t]oggle";
						}
						{
							__unkeyed-1 = "gr";
							group = "LSP Actions";
							mode = "n";
						}
					];
				};
			};

	    # LSP, Completions, Linters, and Formatting
			# -----------------------------------------
			fidget.enable = true; # progress messages in the bottom right
			lspconfig.enable = true; # good defaults for lsps

			# Completion
			luasnip.enable = true;
			blink-cmp = {
				enable = true;

				settings = {
					completion.documentation.auto_show = true;
				
					snippets.preset = "luasnip";

					signature.enabled = true;
				};
			};

			# Formatter
			conform-nvim = {
				enable = true;

				settings.formatters_by_ft = {
					lua = [ "stylua" ];
					nix = [ "alejandra" ];
				};
			};

			lint = {
				enable = true;

				lintersByFt = {
					markdown = [
						"markdownlint-cli2"
					];
				};
			};

			treesitter = {
				enable = true;
				highlight.enable = true;
				indent.enable = true;
				folding.enable = true;

				grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
					bash
					c
					diff
					dockerfile
					go
					graphql
					helm
					html
					java
					javascript
					jsdoc
					json
					kotlin
					lua
					luadoc
					make
					markdown
					markdown_inline
					nix
					nu
					proto
					python
					query
					regex
					rust
					scss
					sql
					toml
					typescript
					vim
					vimdoc
					xml
					yaml
				];
			};

			# Testing and Debugger
			# --------------------
			dap.enable = true;
			dap-ui.enable = true;
			neotest = {
				enable = true;

				# does this provide the adapters for dap?
				adapters = {
					# bash.enable = true;
					# go.enable = true;
					# gradle.enable = true;
					# java.enable = true;
					# jest.enable = true;
					# playwright.enable = true;
					# python.enable = true;
					rust.enable = true;
				};
			};
		};

		lsp = {
			keymaps = [
				{ key = "grn"; lspBufAction = "rename";      options.desc = "re[n]ame"; }
				{ key = "gra"; lspBufAction = "code_action"; options.desc = "[a]ction"; mode = ["n" "x"]; }
				{ key = "grD"; lspBufAction = "declaration"; options.desc = "[D]eclaration"; }
			];

			servers = {
				bashls.enable = true;
				# copilot.enable = true;
				cssls.enable = true;
				gopls.enable = true;
				helm_ls.enable = true;
				html.enable = true;
				java_language_server.enable = true;
				jsonls.enable = true;
				kotlin_language_server.enable = true;
				lua_ls.enable = true;
				marksman.enable = true;
				nixd.enable = true;
				nushell.enable = true;
				postgres_lsp.enable = true;
				pyright.enable = true;
				rust_analyzer.enable = true;
				svelte.enable = true;
				ts_ls.enable = true;
				yamlls.enable = true;
			};
		};
	};
}
