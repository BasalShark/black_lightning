import "sweetalert"

import 'core-js/stable'
import 'regenerator-runtime/runtime'

import 'jquery-slimscroll'

import '../src/jquery.switch'
import '../src/alerts'
import '../src/admin/md_editor'
import '../src/konami_code'

import "controllers"

// BOOTSTRAP: Does it need the below?
//require.context('./../../../node_modules/jquery-ui/ui')
require("@rails/ujs").start()
require("@rails/activestorage").start()

// Requires jQuery. There are vanilla js packages, but not as frequently maintained or downloaded.
require("@nathanvda/cocoon")
