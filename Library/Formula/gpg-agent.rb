require 'formula'

class GpgAgent < Formula
  homepage 'http://www.gnupg.org/'
  url 'ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-2.0.22.tar.bz2'
  sha1 '9ba9ee288e9bf813e0f1e25cbe06b58d3072d8b8'
  revision 1

  depends_on 'libgpg-error'
  depends_on 'libgcrypt'
  depends_on 'libksba'
  depends_on 'libassuan'
  depends_on 'pth'
  depends_on 'pinentry'

  # Adjust package name to fit our scheme of packaging both
  # gnupg 1.x and 2.x, and gpg-agent separately
  def patches; DATA; end

  def install
    # don't use Clang's internal stdint.h
    ENV['gl_cv_absolute_stdint_h'] = "#{MacOS.sdk_path}/usr/include/stdint.h"

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-agent-only",
                          "--with-pinentry-pgm=#{Formula['pinentry'].opt_prefix}/bin/pinentry",
                          "--with-scdaemon-pgm=#{Formula['gnupg2'].opt_prefix}/libexec/scdaemon"
    system "make install"

    plist_path.write startup_plist
    plist_path.chmod 0644
  end

  def caveats
    <<-EOS.undent
    If this is your first install, automatically load on login with:
        sudo cp -vf #{plist_path} /Library/LaunchAgents/
        sudo chown -v root:wheel /Library/LaunchAgents/#{plist_path.basename}
        launchctl load -w /Library/LaunchAgents/#{plist_path.basename}

    If this is an upgrade and you already have the #{plist_path.basename} loaded:
        launchctl unload -w /Library/LaunchAgents/#{plist_path.basename}
        sudo cp #{plist_path} /Library/LaunchAgents/
        sudo chown -v root:wheel /Library/LaunchAgents/#{plist_path.basename}
        launchctl load -w /Library/LaunchAgents/#{plist_path.basename}

      To start gpg-agent manually:
        gpg-agent --daemon
    EOS
  end

  def startup_plist
    return <<-EOPLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>#{plist_name}</string>
    <key>ProgramArguments</key>
    <array>
        <string>#{HOMEBREW_PREFIX}/bin/gpg-agent</string>
        <string>--launchd</string>
        <string>--write-env-file</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>LimitLoadToSessionType</key>
    <string>Aqua</string>
    <key>ServiceIPC</key>
    <true/>
</dict>
</plist>
EOPLIST
  end

end

__END__
diff --git a/configure b/configure
index e5479af..782299d 100755
--- a/configure
+++ b/configure
@@ -578,8 +578,8 @@ MFLAGS=
 MAKEFLAGS=
 
 # Identity of this package.
-PACKAGE_NAME='gnupg'
-PACKAGE_TARNAME='gnupg'
+PACKAGE_NAME='gpg-agent'
+PACKAGE_TARNAME='gpg-agent'
 PACKAGE_VERSION='2.0.22'
 PACKAGE_STRING='gnupg 2.0.22'
 PACKAGE_BUGREPORT='http://bugs.gnupg.org'
diff --git a/agent/gpg-agent.c b/agent/gpg-agent.c
index b00d899..e70f31b 100644
--- a/agent/gpg-agent.c
+++ b/agent/gpg-agent.c
@@ -37,6 +37,10 @@
 #include <unistd.h>
 #include <signal.h>
 #include <pth.h>
+#define HAVE_LAUNCH 1
+#ifdef HAVE_LAUNCH
+# include <launch.h>
+#endif
 
 #define JNLIB_NEED_LOG_LOGV
 #define JNLIB_NEED_AFLOCAL
@@ -75,6 +79,9 @@ enum cmd_and_opt_values
   oLogFile,
   oServer,
   oDaemon,
+#ifdef HAVE_LAUNCH
+  oLaunchd,
+#endif
   oBatch,
 
   oPinentryProgram,
@@ -122,6 +129,9 @@ static ARGPARSE_OPTS opts[] = {
 
   { oServer,   "server",     0, N_("run in server mode (foreground)") },
   { oDaemon,   "daemon",     0, N_("run in daemon mode (background)") },
+#ifdef HAVE_LAUNCH
+  { oLaunchd,   "launchd",   0, N_("run in the foreground, under launched control") },
+#endif
   { oVerbose, "verbose",     0, N_("verbose") },
   { oQuiet,	"quiet",     0, N_("be somewhat more quiet") },
   { oSh,	"sh",        0, N_("sh-style command output") },
@@ -441,6 +451,63 @@ cleanup (void)
 {
   remove_socket (socket_name);
   remove_socket (socket_name_ssh);
+#ifdef HAVE_LAUNCH
+  // Remove environment variables back from launchd.
+  launch_data_t resp, tmp, msg;
+
+  msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+
+  tmp = launch_data_new_string("GPG_AGENT_INFO");
+  launch_data_dict_insert(msg, tmp, "UnsetUserEnvironment");
+
+  resp = launch_msg(msg);
+  launch_data_free(msg); // Do NOT launch_data_free() on tmp
+
+  if (resp) 
+    {
+      launch_data_free(resp);
+    } 
+  else
+    {
+      log_error ("failed to remove environment variable GPG_AGENT_INFO from launchd: %s\n", strerror (errno));
+    }         
+
+  if (opt.ssh_support)
+    {
+      msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+
+      tmp = launch_data_new_string("SSH_AUTH_SOCK");
+      launch_data_dict_insert(msg, tmp, "UnsetUserEnvironment");
+
+      resp = launch_msg(msg);
+      launch_data_free(msg); // Do NOT launch_data_free() on tmp
+
+      if (resp) 
+        {
+          launch_data_free(resp);
+        } 
+      else
+        {
+          log_error ("failed to remove environment variable SSH_AUTH_SOCK from launchd: %s\n", strerror (errno));
+        }         
+      msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+
+      tmp = launch_data_new_string("SSH_AGENT_PID");
+      launch_data_dict_insert(msg, tmp, "UnsetUserEnvironment");
+
+      resp = launch_msg(msg);
+      launch_data_free(msg); // Do NOT launch_data_free() on tmp
+
+      if (resp) 
+        {
+          launch_data_free(resp);
+        } 
+      else
+        {
+          log_error ("failed to remove environment variable SSH_AGENT_PID from launchd: %s\n", strerror (errno));
+        }         
+    }
+#endif
 }
 
 
@@ -561,6 +628,9 @@ main (int argc, char **argv )
   int nogreeting = 0;
   int pipe_server = 0;
   int is_daemon = 0;
+#ifdef HAVE_LAUNCH
+  int launchd_child = 0;
+#endif
   int nodetach = 0;
   int csh_style = 0;
   char *logfile = NULL;
@@ -777,6 +847,9 @@ main (int argc, char **argv )
         case oSh: csh_style = 0; break;
         case oServer: pipe_server = 1; break;
         case oDaemon: is_daemon = 1; break;
+#ifdef HAVE_LAUNCH
+        case oLaunchd: launchd_child = 1; break;
+#endif
 
         case oDisplay: default_display = xstrdup (pargs.r.ret_str); break;
         case oTTYname: default_ttyname = xstrdup (pargs.r.ret_str); break;
@@ -812,6 +885,19 @@ main (int argc, char **argv )
         default : pargs.err = configfp? 1:2; break;
 	}
     }
+    
+  /* When running under launchd control, only start for real users ie UID >= 500
+     Do this check early to avoid filling logs */
+
+  /* HAVE_LAUNCH implies non-Windows system */
+#ifdef HAVE_LAUNCH
+  if (1 == launchd_child && geteuid() < 500)
+    {
+      log_error ("launchd only supported for real users - ie UID >= 500\n");
+      exit (1);
+    }     
+#endif
+
   if (configfp)
     {
       fclose( configfp );
@@ -932,7 +1018,11 @@ main (int argc, char **argv )
   /* If this has been called without any options, we merely check
      whether an agent is already running.  We do this here so that we
      don't clobber a logfile but print it directly to stderr. */
+#ifdef HAVE_LAUNCH
+  if (!pipe_server && !is_daemon && !launchd_child)
+#else
   if (!pipe_server && !is_daemon)
+#endif
     {
       log_set_prefix (NULL, JNLIB_LOG_WITH_PREFIX);
       check_for_running_agent (0, 0);
@@ -994,6 +1084,186 @@ main (int argc, char **argv )
       agent_deinit_default_ctrl (ctrl);
       xfree (ctrl);
     }
+#ifdef HAVE_LAUNCH
+  else if (launchd_child)
+    { /* Launchd-compatible mode */
+      gnupg_fd_t fd;
+      gnupg_fd_t fd_ssh;
+      pid_t pid;
+
+      /* Remove the DISPLAY variable so that a pinentry does not
+         default to a specific display.  There is still a default
+         display when gpg-agent was started using --display or a
+         client requested this using an OPTION command.  Note, that we
+         don't do this when running in reverse daemon mode (i.e. when
+         exec the program given as arguments). */
+#ifndef HAVE_W32_SYSTEM
+      if (!opt.keep_display && !argc)
+        unsetenv ("DISPLAY");
+#endif
+
+      /* Create the sockets.  */
+      socket_name = create_socket_name ("S.gpg-agent",
+                                        "/tmp/gpg-XXXXXX/S.gpg-agent");
+      if (opt.ssh_support)
+	socket_name_ssh = create_socket_name ("S.gpg-agent.ssh",
+                                            "/tmp/gpg-XXXXXX/S.gpg-agent.ssh");
+
+      fd = create_server_socket (socket_name, 0, &socket_nonce);
+      if (opt.ssh_support)
+	fd_ssh = create_server_socket (socket_name_ssh, 1, &socket_nonce_ssh);
+      else
+	fd_ssh = GNUPG_INVALID_FD;
+
+      fflush (NULL);
+#ifdef HAVE_W32_SYSTEM
+      pid = getpid ();
+      printf ("set GPG_AGENT_INFO=%s;%lu;1\n", socket_name, (ulong)pid);
+#else /*!HAVE_W32_SYSTEM*/
+      pid = getpid ();
+
+          char *infostr, *infostr_ssh_sock, *infostr_ssh_pid;
+          
+          /* Create the info string: <name>:<pid>:<protocol_version> */
+          if (asprintf (&infostr, "GPG_AGENT_INFO=%s:%lu:1",
+                        socket_name, (ulong)pid ) < 0)
+            {
+              log_error ("out of core\n");
+              kill (pid, SIGTERM);
+              exit (1);
+            }
+	  if (opt.ssh_support)
+	    {
+	      if (asprintf (&infostr_ssh_sock, "SSH_AUTH_SOCK=%s",
+			    socket_name_ssh) < 0)
+		{
+		  log_error ("out of core\n");
+		  kill (pid, SIGTERM);
+		  exit (1);
+		}
+	      if (asprintf (&infostr_ssh_pid, "SSH_AGENT_PID=%u",
+			    pid) < 0)
+		{
+		  log_error ("out of core\n");
+		  kill (pid, SIGTERM);
+		  exit (1);
+		}
+	    }
+
+          if (env_file_name)
+            {
+              FILE *fp;
+              
+              fp = fopen (env_file_name, "w");
+              if (!fp)
+                log_error (_("error creating `%s': %s\n"),
+                             env_file_name, strerror (errno));
+              else
+                {
+                  fputs (infostr, fp);
+                  putc ('\n', fp);
+                  if (opt.ssh_support)
+                    {
+                      fputs (infostr_ssh_sock, fp);
+                      putc ('\n', fp);
+                      fputs (infostr_ssh_pid, fp);
+                      putc ('\n', fp);
+                    }
+                  fclose (fp);
+                }
+            }
+
+          // Pass environment variables back to launchd.
+          launch_data_t resp, tmp, tmpv, msg;
+    
+          msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+          tmp = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+    
+          tmpv = launch_data_new_string(strchr(infostr, '=') + 1); // Skip variable name and equal sign
+          launch_data_dict_insert(tmp, tmpv, "GPG_AGENT_INFO");
+          launch_data_dict_insert(msg, tmp, "SetUserEnvironment");
+    
+          resp = launch_msg(msg);
+          launch_data_free(msg); // Do NOT launch_data_free() on tmp, nor tmpv
+    
+          if (resp) 
+            {
+              launch_data_free(resp);
+            } 
+          else
+            {
+              log_error ("failed to pass environment variable GPG_AGENT_INFO to launchd: %s\n", strerror (errno));
+              kill (pid, SIGTERM);
+              exit (1);
+            }         
+        
+          if (opt.ssh_support)
+            {
+              msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+              tmp = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+        
+              tmpv = launch_data_new_string(strchr(infostr_ssh_sock, '=') + 1); // Skip variable name and equal sign
+              launch_data_dict_insert(tmp, tmpv, "SSH_AUTH_SOCK");
+              launch_data_dict_insert(msg, tmp, "SetUserEnvironment");
+        
+              resp = launch_msg(msg);
+              launch_data_free(msg); // Do NOT launch_data_free() on tmp, nor tmpv
+        
+              if (resp) 
+                {
+                  launch_data_free(resp);
+                } 
+              else
+                {
+                  log_error ("failed to pass environment variable SSH_AUTH_SOCK to launchd: %s\n", strerror (errno));
+                  kill (pid, SIGTERM);
+                  exit (1);
+                }         
+              msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+              tmp = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
+        
+              tmpv = launch_data_new_string(strchr(infostr_ssh_pid, '=') + 1); // Skip variable name and equal sign
+              launch_data_dict_insert(tmp, tmpv, "SSH_AGENT_PID");
+              launch_data_dict_insert(msg, tmp, "SetUserEnvironment");
+        
+              resp = launch_msg(msg);
+              launch_data_free(msg); // Do NOT launch_data_free() on tmp, nor tmpv
+        
+              if (resp) 
+                {
+                  launch_data_free(resp);
+                } 
+              else
+                {
+                  log_error ("failed to pass environment variable SSH_AGENT_PID to launchd: %s\n", strerror (errno));
+                  kill (pid, SIGTERM);
+                  exit (1);
+                }         
+            }
+
+
+      {
+        struct sigaction sa;
+        
+        sa.sa_handler = SIG_IGN;
+        sigemptyset (&sa.sa_mask);
+        sa.sa_flags = 0;
+        sigaction (SIGPIPE, &sa, NULL);
+      }
+#endif /*!HAVE_W32_SYSTEM*/
+
+      handle_connections (fd, opt.ssh_support ? fd_ssh : GNUPG_INVALID_FD);
+
+      if (env_file_name)
+        {
+          if (unlink(env_file_name))
+            log_error (_("error deleting `%s': %s\n"),
+                         env_file_name, strerror (errno));
+        }
+
+      assuan_sock_close (fd);
+    }
+#endif /*HAVE_LAUNCH*/
   else if (!is_daemon)
     ; /* NOTREACHED */
   else
