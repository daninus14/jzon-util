(defsystem "jzon-util"
  :version "0.1.0"
  :author "Daniel Nussenbaum"
  :license "MIT"
  :depends-on ("com.inuoe.jzon"
               "closer-mop")
  :components ((:module "src"
                :components
                ((:file "packages")
                 (:file "sensitive"))))
  :description "Utilities for com.inuoe.jzon")
