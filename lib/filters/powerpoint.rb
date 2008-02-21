# Microsoft Powerpoint to text conversion:
#   Program: catppt
#   Version tested: Catdoc Version 0.94.2
#   Installation: Ubuntu package
#   Home page: http://www.wagner.pp.ru/~vitus/software/catdoc/

PlainText.extract {
  from :ppt, :pps
  as "application/powerpoint"
  aka "Microsoft Office Powerpoint document"
  with "catppt  SOURCE > DESTINATION 2>/dev/null" => :on_linux, "some other command" => :on_windows
}