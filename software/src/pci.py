import sys, string, traceback
import pygtk
import gobject
import pango
import gtk
import gtk.keysyms

import gtkwave;

gtkwave.list()
gtkwave.add('top.FRAMEn');
gtkwave.add('top.AD');
gtkwave.add('top.CBE');
gtkwave.add('top.IRDYn');
gtkwave.add('top.TRDYn');
gtkwave.add('top.DEVSELn');
gtkwave.add('top.IDSEL');
gtkwave.add('top.PAR');
gtkwave.add('top.GNTn');
gtkwave.add('top.LOCKn');
gtkwave.add('top.PERRn');
gtkwave.add('top.REQn');
gtkwave.add('top.SERRn');
gtkwave.add('top.STOPn');
gtkwave.add('top.Transaction');
gtkwave.add('top.Targeted');
gtkwave.add('top.DevSelOE');
gtkwave.add('top.DevSel');
gtkwave.add('top.ConfigSpace');
gtkwave.add('top.IoSpace');
gtkwave.add('top.MemSpace');
gtkwave.add('top.ReadnWrite');

gtkwave.show()

gtk.main()
