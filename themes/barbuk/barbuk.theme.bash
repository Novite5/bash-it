# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Prompt defaut configuration
BARBUK_PROMPT=${BARBUK_PROMPT:="git-upstream-remote-logo ssh path scm python_venv uv ruby node bun docker pre_commit terraform mysql ansible cloud duration exit"}

# Theme custom glyphs
# SCM
SCM_GIT_CHAR_GITLAB=${BARBUK_GITLAB_CHAR:='  '}
SCM_GIT_CHAR_BITBUCKET=${BARBUK_BITBUCKET_CHAR:='  '}
SCM_GIT_CHAR_GITHUB=${BARBUK_GITHUB_CHAR:='  '}
SCM_GIT_CHAR_ARCHLINUX=${BARBUK_ARCHLINUX_CHAR:='  '}
SCM_GIT_CHAR_CODEBERG=${BARBUK_CODEBERG_CHAR:='  '}
SCM_GIT_CHAR_DEFAULT=${BARBUK_GIT_DEFAULT_CHAR:='  '}
SCM_GIT_CHAR_ICON_BRANCH=${BARBUK_GIT_BRANCH_ICON:=''}
SCM_HG_CHAR=${BARBUK_HG_CHAR:='☿ '}
SCM_SVN_CHAR=${BARBUK_SVN_CHAR:='⑆ '}
SCM_THEME_CURRENT_USER_PREFFIX=${normal?}${BARBUK_CURRENT_USER_PREFFIX:='  '}
# Exit code
EXIT_CODE_ICON=${BARBUK_EXIT_CODE_ICON:=' '}
# Programming and tools
PRE_COMMIT_CHAR=${BARBUK_PRE_COMMIT_CHAR:=' '}
PREK_CHAR=${BARBUK_PREK_CHAR:='⚡'}
PYTHON_VENV_CHAR=${BARBUK_PYTHON_VENV_CHAR:=' '}
UV_CHAR=${BARBUK_UV_CHAR:='🐍'}
RUBY_CHAR=${BARBUK_RUBY_CHAR:=' '}
NODE_CHAR=${BARBUK_NODE_CHAR:=' '}
BUN_CHAR=${BARBUK_BUN_CHAR:='🍞 '}
TERRAFORM_CHAR=${BARBUK_TERRAFORM_CHAR:="❲t❳ "}
DOCKER_CHAR=${BARBUK_DOCKER_CHAR:=" "}
MYSQL_CHAR=${BARBUK_MYSQL_CHAR:=" "}
MARIADB_CHAR=${BARBUK_MARIADB_CHAR:=" "}
ANSIBLE_CHAR=${BARBUK_ANSIBLE_CHAR:=" "}
# Cloud
AWS_PROFILE_CHAR=${BARBUK_AWS_PROFILE_CHAR:=" aws "}
SCALEWAY_PROFILE_CHAR=${BARBUK_SCALEWAY_PROFILE_CHAR:=" scw "}
GCLOUD_CHAR=${BARBUK_GCLOUD_CHAR:=" google "}

# Command duration
: "${COMMAND_DURATION_MIN_SECONDS:=1}"
: "${COMMAND_DURATION_COLOR:="${normal?}"}"

# Ssh user and hostname display
SSH_INFO=${BARBUK_SSH_INFO:=true}
HOST_INFO=${BARBUK_HOST_INFO:=long}

# Home info display
ANSIBLE_HOME_DISPLAY=${BARBUK_ANSIBLE_HOME_DISPLAY:=false}

# Bash-it default glyphs overrides
SCM_NONE_CHAR=
SCM_THEME_PROMPT_DIRTY=" ${bold_red?}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
SCM_THEME_PROMPT_PREFIX="|"
SCM_THEME_PROMPT_SUFFIX="${green?}| "
SCM_GIT_BEHIND_CHAR="${bold_red?}↓${normal?}"
SCM_GIT_AHEAD_CHAR="${bold_green?}↑${normal?}"
SCM_GIT_UNTRACKED_CHAR="⌀"
SCM_GIT_UNSTAGED_CHAR="${bold_yellow?}•${normal?}"
SCM_GIT_STAGED_CHAR="${bold_green?}+${normal?}"
GIT_THEME_PROMPT_DIRTY=" ${bold_red?}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green?}✓"
GIT_THEME_PROMPT_PREFIX="${cyan?}"
GIT_THEME_PROMPT_SUFFIX="${cyan?}"
SCM_THEME_BRANCH_TRACK_PREFIX="${normal?} ⤏  ${cyan?}"
SCM_THEME_BRANCH_GONE_PREFIX="${normal?} ↛  ${red?}"
NVM_THEME_PROMPT_PREFIX=''
NVM_THEME_PROMPT_SUFFIX=''
RVM_THEME_PROMPT_PREFIX=''
RVM_THEME_PROMPT_SUFFIX=''
RBENV_THEME_PROMPT_PREFIX=' '
RBENV_THEME_PROMPT_SUFFIX=''
RBFU_THEME_PROMPT_PREFIX=''
RBFU_THEME_PROMPT_SUFFIX=''

function __get_domain_from_git_remote() {
	local git_remote="$1"
	echo "$git_remote" | awk -F'[@:]' '$1 ~ /ssh/ {domain=$3} $1 ~ /https/ {domain=$2} $1 ~ /git/ {domain=$2} { sub("//", "", domain); sub(/\/.*$/, "", domain); print domain }'
}

function __git-upstream-remote-logo_prompt() {
	[[ -z "$(_git-upstream)" ]] && SCM_GIT_CHAR="${SCM_GIT_CHAR_DEFAULT:-}"

	local remote remote_domain
	remote="$(_git-upstream-remote)"

	if [ -z "$remote" ]; then
		remote=$(git ls-remote --get-url 2> /dev/null)
	else
		remote=$(git config --get remote."${remote}".url)
	fi

	remote_domain=$(__get_domain_from_git_remote "$remote")

	case "${remote_domain}" in
		github.com) SCM_GIT_CHAR="${SCM_GIT_CHAR_GITHUB:-}" ;;
		gitlab.com) SCM_GIT_CHAR="${SCM_GIT_CHAR_GITLAB:-}" ;;
		bitbucket.com) SCM_GIT_CHAR="${SCM_GIT_CHAR_BITBUCKET:-}" ;;
		codeberg.org) SCM_GIT_CHAR="${SCM_GIT_CHAR_CODEBERG:-}" ;;
		aur.archlinux.org) SCM_GIT_CHAR="${SCM_GIT_CHAR_ARCHLINUX:-}" ;;
		*) SCM_GIT_CHAR="${SCM_GIT_CHAR_DEFAULT:-}" ;;
	esac

	echo "${purple?}$(scm_char)"
}

function git_prompt_info() {
	git_prompt_vars
	echo -e "on $SCM_GIT_CHAR_ICON_BRANCH $SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_GIT_AHEAD$SCM_GIT_BEHIND$SCM_GIT_STASH$SCM_SUFFIX "
}

function __exit_prompt() {
	if [[ "$exit_code" -ne 0 ]]; then
		echo "${purple?}${EXIT_CODE_ICON}${yellow?}${exit_code}${bold_orange?} "
	else
		echo "${bold_green?}"
	fi
}

function __aws_profile_prompt() {
	if [[ -n "${AWS_PROFILE:-}" ]]; then
		echo -n "${bold_purple?}${AWS_PROFILE_CHAR}${normal?}${AWS_PROFILE} "
	fi
}

function __scaleway_profile_prompt() {
	if [[ -n "${SCW_PROFILE:-}" ]]; then
		echo -n "${bold_purple?}${SCALEWAY_PROFILE_CHAR}${normal?}${SCW_PROFILE} "
	fi
}

function __gcloud_prompt() {
	local active_gcloud_account=""

	active_gcloud_account="$(active_gcloud_account_prompt)"
	[[ -n "${active_gcloud_account}" ]] && echo "${bold_purple?}${GCLOUD_CHAR}${normal?}${active_gcloud_account} "
}

function __cloud_prompt() {
	__aws_profile_prompt
	__scaleway_profile_prompt
	__gcloud_prompt
}

function __terraform_prompt() {
	local terraform_workspace=""

	if [ -d .terraform ]; then
		terraform_workspace="$(terraform_workspace_prompt)"
		[[ -n "${terraform_workspace}" ]] && echo "${bold_purple?}${TERRAFORM_CHAR}${normal?}${terraform_workspace} "
	fi
}

function __node_prompt() {
	local node_version=""

	node_version="$(node_version_prompt)"
	[[ -n "${node_version}" ]] && echo "${bold_purple?}${NODE_CHAR}${normal?}${node_version} "
}

function __bun_prompt() {
	if [[ -f bun.lockb || -f bun.lock || -f bunfig.toml ]]; then
		local bun_version=""
		if _command_exists bun; then
			bun_version=$(bun --version 2> /dev/null)
		fi
		echo "${bold_purple?}${BUN_CHAR}${normal?}${bun_version} "
	fi
}

function __ruby_prompt() {
	local ruby_version=""

	ruby_version="$(ruby_version_prompt)"
	[[ -n "${ruby_version}" ]] && echo "${bold_purple?}${RUBY_CHAR}${normal?}${ruby_version} "
}

function __ssh_prompt() {
	# Detect ssh
	if [[ -n "${SSH_CONNECTION:-}" && "${SSH_INFO:-}" == true ]]; then
		if [[ "${HOST_INFO:-}" == long ]]; then
			host="\H"
		else
			host="\h"
		fi
		echo "${bold_blue?}\u${bold_orange?}@${cyan?}$host ${bold_orange?}in "
	fi
}

function __python_venv_prompt() {
	local python_info=""
	if [[ -n "${CONDA_DEFAULT_ENV:-}" ]]; then
		python_info="${CONDA_DEFAULT_ENV}"
	elif [[ -n "${VIRTUAL_ENV_PROMPT:-}" ]]; then
		python_info="${VIRTUAL_ENV_PROMPT}"
	elif [[ -f pyproject.toml ]]; then
		python_info=$(awk -F'"' '/^requires-python/ {print $2}' pyproject.toml)
		[[ -z "${python_info}" ]] && python_info="py"
	fi

	if [[ -n "${python_info}" ]]; then
		echo "${bold_purple?}$PYTHON_VENV_CHAR${normal?}${python_info} "
	fi
}

function __uv_prompt() {
	if [[ -f uv.lock ]]; then
		echo "${bold_purple?}${UV_CHAR}${normal?} "
	fi
}

function __pre_commit_prompt() {
	if [[ -f .pre-commit-config.yaml ]]; then
		local icon="${PRE_COMMIT_CHAR}"
		if [[ -f .git/hooks/pre-commit ]]; then
			if grep -q "prek" .git/hooks/pre-commit 2> /dev/null; then
				icon="${PREK_CHAR}"
			fi
		fi
		echo "${bold_purple?}${icon}${normal?} "
	fi
}

function __path_prompt() {
	local dir_color=${green?}
	# Detect root shell
	if [ "$(whoami)" = root ]; then
		dir_color=${red?}
	fi

	echo "${dir_color}\w${normal?} "
}

function __scm_prompt() {
	scm_prompt_info
}

function __duration_prompt() {
	[[ -n "$command_duration" ]] && echo "${command_duration} "
}

function __docker_prompt() {
	local docker_context=''

	if [ -f compose.yml ] || [ -f docker-compose.yml ] || [ -f Dockerfile ]; then
		if [ -n "$DOCKER_CONTEXT" ]; then
			docker_context="$DOCKER_CONTEXT"
		elif [ -n "$DOCKER_HOST" ]; then
			docker_context="$DOCKER_HOST"
		elif [ -f .env ] && grep -qF COMPOSE_PROJECT_NAME .env; then
			docker_context=$(awk -F'[ \t\n=]+' '/COMPOSE_PROJECT_NAME/ {print $2; exit}' .env)
		fi
		echo "${bold_blue?}${DOCKER_CHAR}${normal?}${docker_context} "
	fi
}

function __mysql_prompt() {
	# \R displays current time in 24 HR format
	# \m displays the minutes
	# \s displays the seconds
	# \U displays username@hostname accountname
	# \c displays a mysql statement counter. keeps increasing as you type commands.
	# \d displays default database
	export MYSQL_PS1="\R:\m:\s (\U) \c [\d]> "

	local user char

	if [ -f "$HOME/.my.cnf" ]; then
		user=$(awk -F'[ \t\n=]+' '/user/ {print $2; exit}' "$HOME/.my.cnf")
		char="$MYSQL_CHAR"
		if [ -n "$user" ]; then
			if _command_exists mariadb; then
				char="$MARIADB_CHAR"
			fi
			echo "${bold_blue?}${char}${normal?}${user} "
		fi
	fi
}

function __ansible_prompt() {
	local config
	# Ansible will check:
	# ANSIBLE_CONFIG (environment variable if set)
	# ansible.cfg (in the current directory)
	# ~/.ansible.cfg (in the home directory)
	# /etc/ansible/ansible.cfg
	#
	# Ansible will process the above list and use the first file found, all others are ignored.
	if [ -n "${ANSIBLE_CONFIG:-}" ]; then
		config="$ANSIBLE_CONFIG"
	elif [ -f ansible.cfg ]; then
		config=ansible.cfg
	elif [ -f "$HOME/.ansible.cfg" ] && [ "$ANSIBLE_HOME_DISPLAY" = true ]; then
		# shellcheck disable=SC2088
		config="~/.ansible.cfg"
	elif [ -f /etc/ansible/ansible.cfg ]; then
		config="/etc/ansible/ansible.cfg"
	fi

	if [ -n "${config:-}" ]; then
		echo "${bold_purple?}${ANSIBLE_CHAR}${normal?}${config} "
	fi
}

function __prompt-command() {
	exit_code="$?"
	command_duration=$(_command_duration)
	local wrap_char=

	# Generate prompt
	PS1="\n "
	for segment in $BARBUK_PROMPT; do
		local info
		info="$(__"${segment}"_prompt)"
		[[ -n "${info}" ]] && PS1+="${info}"
	done

	# Cut prompt when it's too long
	if [[ ${#PS1} -gt $((COLUMNS * 2)) ]]; then
		wrap_char="\n"
	fi

	PS1="${PS1}${wrap_char}❯${normal?} "
}

safe_append_prompt_command __prompt-command
