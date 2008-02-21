# Microsoft Rich Text Format to text conversion:
#   Program: unrtf
#   Version tested: 0.19.2
#   Installation: Ubuntu unrtf package
#   http://www.gnu.org/software/unrtf/unrtf.html

PlainText.extract {
  from :rtf
  as "application/rtf"
  aka "Microsoft Rich Text Format"
  with "unrtf  SOURCE -t text > DESTINATION 2>/dev/null" => :on_linux, "some other command" => :on_windows
}