#!/usr/bin/env python
# coding=utf-8

"""
Add files to the recently-used list

Overview:

    File dialogs and file managers (like Nautilus) have a "Recently Used" file
    list. Files are not automatically added to this list when they are created.
    Sometimes it would be nice to have scripts that generate files also add
    them to this list. For example, a script that takes screenshots can also
    add the resulting file(s) to the recently used list, making it easier to
    grab a screenshot and then open it in GIMP or Inkscape.
"""

from __future__ import print_function

__copyright__ = "Copyright ©2016 Laurence Gonsalves"
__license__   = "GPLv2"
__email__     = "laurence@xenomachina.com"

import argparse
import os.path
import sys

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gio
from gi.repository import GLib
from gi.repository import Gtk

class UserError(Exception):
    def __init__(self, message):
        self.message = message


def create_argparser():
    description, epilog = __doc__.strip().split('\n', 1)
    parser = argparse.ArgumentParser(description=description, epilog=epilog,
            formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('-A', '--appname',
        help="Application name (defaults to name of this script)")
    parser.add_argument('file',
        help="File to add to recently used list",
        nargs='*')
    return parser


def warn(msg):
    print('WARNING: ' + msg, file=sys.stderr)


def main(args):
    if args.appname:
        GLib.set_application_name(args.appname)

    # Add files to list
    recent_mgr = Gtk.RecentManager.get_default()
    for path in args.file:
        file = Gio.File.new_for_path(path)
        if not file.query_exists():
            warn("%r doesn't exist" % path)
        else:
            uri = file.get_uri()
            recent_mgr.add_item(uri)
            print("Adding %r" % uri)

    # RecentManager.add_item is async, so we need to start the main loop for
    # those calls to actually do something. We want to quit as soon as they are
    # complete, so after scheduling them, we schedule an idle task to quit the
    # loop. Note that the order here is important. If the idle task is
    # scheduled first it will execute first!
    GLib.idle_add(Gtk.main_quit)
    Gtk.main()


if __name__ == '__main__':
    error = None
    argparser = create_argparser()
    try:
        main(argparser.parse_args())
    except UserError as exc:
        error = exc.message

    if error is not None:
        print('%s: ERROR: %s' % (argparser.prog, error), file=sys.stderr)
        sys.exit(1)
