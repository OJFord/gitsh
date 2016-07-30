require 'mkmf'

readline = Struct.new(:headers, :extra_check).new(["stdio.h"])

def readline.have_header(header)
  if super(header, &extra_check)
    headers.push(header)
    return true
  else
    return false
  end
end

def readline.have_var(var)
  return super(var, headers)
end

def readline.require_var(var)
  unless have_var(var)
    raise "found incompatible version of readline (no #{var})"
  end
end

def readline.have_func(func)
  return super(func, headers)
end

def readline.require_func(func)
  unless have_func(func)
    raise "found incompatible version of readline (no #{func})"
  end
end

def readline.have_type(type)
  return super(type, headers)
end

dir_config('curses')
dir_config('ncurses')
dir_config('termcap')
dir_config("readline")

have_library("user32", nil) if /cygwin/ === RUBY_PLATFORM
have_library("ncurses", "tgetnum") ||
  have_library("termcap", "tgetnum") ||
  have_library("curses", "tgetnum")

unless ((readline.have_header("readline/readline.h") &&
         readline.have_header("readline/history.h")) &&
         have_library("readline", "readline"))
  raise "readline not found"
end

readline.require_func("rl_set_screen_size")
readline.require_var("rl_completion_append_character")
readline.require_var("rl_editing_mode")
readline.require_var("rl_line_buffer")
readline.require_var("rl_char_is_quoted_p")
readline.require_var("rl_completion_quote_character")

readline.have_func("rl_getc")
readline.have_func("rl_getc_function")
readline.have_func("rl_filename_completion_function")
readline.have_func("rl_username_completion_function")
readline.have_func("rl_completion_matches")
readline.have_func("rl_refresh_line")
readline.have_var("rl_deprep_term_function")
readline.have_var("rl_completer_word_break_characters")
readline.have_var("rl_completer_quote_characters")
readline.have_var("rl_attempted_completion_over")
readline.have_var("rl_library_version")
readline.have_var("rl_point")
# workaround for native windows.
/mswin|bccwin|mingw/ !~ RUBY_PLATFORM && readline.have_var("rl_event_hook")
/mswin|bccwin|mingw/ !~ RUBY_PLATFORM && readline.have_var("rl_catch_sigwinch")
/mswin|bccwin|mingw/ !~ RUBY_PLATFORM && readline.have_var("rl_catch_signals")
readline.have_var("rl_pre_input_hook")
readline.have_var("rl_special_prefixes")
readline.have_func("rl_cleanup_after_signal")
readline.have_func("rl_free_line_state")
readline.have_func("rl_clear_signals")
readline.have_func("rl_get_screen_size")
readline.have_func("rl_vi_editing_mode")
readline.have_func("rl_emacs_editing_mode")
readline.have_func("replace_history_entry")
readline.have_func("remove_history")
readline.have_func("clear_history")
readline.have_func("rl_redisplay")
readline.have_func("rl_insert_text")
readline.have_func("rl_delete_text")
unless readline.have_type("rl_hook_func_t*")
  # rl_hook_func_t is available since readline-4.2 (2001).
  # Function is removed at readline-6.3 (2014).
  # However, editline (NetBSD 6.1.3, 2014) doesn't have rl_hook_func_t.
  $defs << "-Drl_hook_func_t=Function"
end

have_func("rb_obj_reveal", ["ruby.h"])
have_func("rb_obj_hide", ["ruby.h"])

create_makefile('gitsh/line_editor_native', 'src')
