/* R2Doc
 * Copyright (c) 2009 Jeffrey Hunter and Mission Critical Labs, Inc.
 *
 * Distributable under an MIT-style license.  See LICENSE file for details.
 */


/**
 * 'Namespace' for rdoc-related stuff
 */
var rdoc = {};

/**
 * Utility function for generating the URL from one page to another.
 */
rdoc.genUrl = function(fromUrl, toUrl) {
  var fromItems = fromUrl.split(/\\+|\/+/);
  var toItems = toUrl.split(/\\+|\/+/);
  
  fromItems.pop();
  var toFile = toItems.pop();
  
  while (fromItems.length > 0 && toItems.length > 0 && fromItems[0] == toItems[0]) {
    fromItems.shift();
    toItems.shift();
  }
  
  var url = [];
  for (var i = 0; i < fromItems.length; i++) { url.push('..'); }
  
  url = url.concat(toItems);
  url.push(toFile);
  return url.join('/');
}

/**
 * Base class for custom autocompleters.
 *
 * This class is an abstract class intended for creating your own
 * autocompletion widget.  Derived classes must define the methods
 * delayedUpdate(), determineIds(), setIds(result).  The methods are
 * described in greater detail below.  This class does not provide an
 * initialize method of its own.  It defines a method named
 * baseInitialize which is intended to be called from the derived class's
 * initialize function.
 *
 * The delayedUpdate() method is responsible for retrieving the list of
 * possible autocompletion options.  It typically passes this back by
 * calling newSelections().  newSelections() expects an array of objects
 * representing each possible selection.  At a minimum, each object must
 * provide two properties: display_name and description.  Note that
 * display_name is the value that will be evaluated to see if it matches
 * what the user has typed.
 *
 * The determineIds() method is called when the control loses focus
 * without a selection being chosen through any of the autocompletion
 * means (e.g. by clicking an item, hitting tab, or hitting return).
 * This is an opportunity for the control to perform any cleanup needed
 * for a typed in response (for example, lookup an id based on the typed
 * in text).
 *
 * The setIds() method is called when a specific item from the list of
 * autocompletion options is chosen.  The item chose is passed to the
 * funtion.  If the delayedUpdate() method passes a list of objects to
 * newSelections(), the object passed to setIds() will be the selected
 * object from the list.
 */
rdoc.CustomAutoCompleter = Class.create();
rdoc.CustomAutoCompleter.prototype = {
  /**
   * Constructor
   *
   * @param elem   The element or id to preform autocompletion for
   * @param chooser The element or id of the window that diplays the choices
   */
  baseInitialize: function(elem, chooser) {
    this.element = $(elem);
    this.chooser = $(chooser);
    this.visible = false;
    this.selectedIndex = null;
    this.selectedElem = null;
    this.options = null;
    this.selectionSet = false;
    this.listClickCallback = this.onListClick.bind(this);
    this.updateTimer = null;
    
    // prep the chooser
    this.chooser.style.display = 'none';
    
    // prep the element
    this.element.setAttribute('autocomplete','off');
    Event.observe(this.element, "blur", this.onBlur.bindAsEventListener(this));
    Event.observe(this.element, "keydown", this.onKeyPress.bindAsEventListener(this));
  },

  /**
   * Called when a key is pressed for the autocompleting element
   */
  onKeyPress: function(event) {
    switch(event.keyCode) {
      case Event.KEY_TAB:
      case Event.KEY_RETURN:
        if (this.selectedIndex != null) {
          this.useSelection();
          Event.stop(event);
        }
        return;
        
     case Event.KEY_ESC:
        this.hide();
        Event.stop(event);
        return;
        
      case Event.KEY_LEFT:
      case Event.KEY_RIGHT:
        return;
        
      case Event.KEY_UP:
        this.selectionSet = false;
        this.selectionUp();
        if(navigator.appVersion.indexOf('AppleWebKit')>0) Event.stop(event);
        return;
        
      case Event.KEY_DOWN:
        if (!this.visible) {
          this.updateSelectionsNow();
        } else {
          this.selectionSet = false;
          this.selectionDown();
        }
        if(navigator.appVersion.indexOf('AppleWebKit')>0) Event.stop(event);
        return;
    }
    
    this.selectionSet = false;
    this.updateSelections();
  },

  /**
   * Called when the autocompleting element loses focus
   */
  onBlur: function(event) {
    // to make sure click events work on the list
    setTimeout(this.afterBlur.bind(this), 250);
  },
  
  /**
   * Called after focus has already been lost
   */
  afterBlur: function() {
    if (!this.selectionSet) this.determineIds();
    this.hide();
  },
  
  /**
   * Makes the selected item the new element value
   */
  useSelection: function() {
    if (this.selectedIndex == null) return;
    
    var selected = this.options[this.selectedIndex];
    this.setIds(selected);
    this.hide();
  },
  
  /**
   * Turn off the selection window
   */
  hide: function() {
    this.visible = false;
    this.selectedIndex = null;
    this.selectedElem = null;
    this.chooser.style.display = 'none';
  },
  
  /**
   * Move the selection up one item in the list
   */
  selectionUp: function() {
    if (!this.selectedElem) return;
    if (!this.selectedElem.previousSibling) return;
    
    this.selectedElem.className = '';
    this.selectedElem = this.selectedElem.previousSibling;
    this.selectedIndex = this.selectedElem.optionIndex;
    this.selectedElem.className = 'selected';
    this.scrollIntoView(this.selectedElem);
  },
  
  /**
   * Move the selection down one item in the list
   */
  selectionDown: function() {
    if (!this.selectedElem) {
      this.selectFirst();
      return;
    }
    
    if (!this.selectedElem.nextSibling) return;
    
    this.selectedElem.className = '';
    this.selectedElem = this.selectedElem.nextSibling;
    this.selectedIndex = this.selectedElem.optionIndex;
    this.selectedElem.className = 'selected';
    this.scrollIntoView(this.selectedElem);
  },
  
  /**
   * Select the first element
   */
  selectFirst: function() {
    if (this.options.length > 0) {
      this.selectedIndex = 0;
      this.selectedElem = this.chooser.down('li');
      if (this.selectedElem) {
        this.selectedElem.className = 'selected';
        this.scrollIntoView(this.selectedElem);
        return true;
      } else {
        return false;
      }
    }
    
    return false;
  },

  /**
   * Scroll the list of selections, if necessary, so that the given item is
   * visible
   */
  scrollIntoView: function(elem) {
    var topY = elem.offsetTop - this.chooser.scrollTop;
    var bottomY = topY + elem.offsetHeight;

    // if the top is too high, scroll down
    if (topY < 0) {
      this.chooser.scrollTop = elem.offsetTop;
    // otherwise, if the bottom is too low, scroll up
    } else if (bottomY > this.chooser.clientHeight) {
      this.chooser.scrollTop = elem.offsetTop - this.chooser.clientHeight + elem.offsetHeight;
    }
  },
  
  /**
   * Click event handler for list items
   */
  onListClick: function(event) {
    var li = Event.findElement(event, 'LI');
    if (!li) return;
    
    if (this.selectedElem) this.selectedElem.className = '';
    
    this.selectedElem = li;
    this.selectedIndex = li.optionIndex;
    li.className = 'selected';
    this.useSelection();
  },
  
  /**
   * Update the list of selections
   */
  updateSelections: function() {
    this.visible = true;
    if (this.updateTimer != null) clearTimeout(this.updateTimer);
    this.updateTimer = setTimeout(this.delayedUpdate.bind(this), 250);
  },
  
  /**
   * Perform an immediate update the list of selections
   */
  updateSelectionsNow: function() {
    this.visible = true;
    if (this.updateTimer != null) clearTimeout(this.updateTimer);
    this.updateTimer = setTimeout(this.delayedUpdate.bind(this), 1);
  },

  /**
   * Called when new selections are retrieved
   */
  newSelections: function(allOptions, preserveSelectedIndex) {
    if (!this.visible) return;
    
    var txt = this.element.value.toUpperCase();
    
    // examine all possibilities and show only those beginning with the currently entered text
    this.options = [];
    var i;
    for (i = 0; i < allOptions.length; i++) {
      if (allOptions[i].display_name.substring(0, txt.length).toUpperCase() == txt)
        this.options.push(allOptions[i]);
    }

    if (!preserveSelectedIndex)
      this.selectedIndex = 0;
    this.updateDisplay();
  },
  
  /**
   * Update the selection box with a new set of options
   */
  updateDisplay: function() {
    // just hide the display if nothing matches
    if (this.options.length == 0) {
      this.hide();
      return;
    }
    
    // create the list
    var ul = document.createElement('UL');
    var idx = 0;
    
    while (idx < this.options.length) {
      var li = document.createElement('LI');
      li.innerHTML = this.options[idx].display_name.escapeHTML() + ' <span class="description">' + this.options[idx].description.escapeHTML() + '</span>';
      li.optionIndex = idx;
      Event.observe(li, 'click', this.listClickCallback);
      if (this.selectedIndex == idx) {
        li.className = 'selected';
        this.selectedElem = li;
      }
      ul.appendChild(li);
      idx++;
    }
    
    // populate the display
    while (this.chooser.hasChildNodes()) { this.chooser.removeChild(this.chooser.childNodes[0]); }
    this.chooser.appendChild(ul);
    
    if (this.chooser.style.display != 'block') {
      this.chooser.style.zIndex = 1;
      this.chooser.style.position = 'absolute';
      this.positionChooser();
      this.displayChooser();
    }
  },
  
  /**
   * Set the position for the chooser window
   */
  positionChooser: function() {
    Position.clone(this.element, this.chooser, {setHeight: false, offsetTop: this.element.offsetHeight});
  },
  
  /**
   * Effect for displaying the chooser.  Can be overridden.
   */
  displayChooser: function() {
    jQuery(this.chooser).slideDown('fast');
  }
};

/**
 * Base class for custom modal dialogs
 *
 * Supported options:
 *   maskOpacity - Opacity (0.0 to 1.0) of the background behind the dialog
 *   maskColor   - Color of the background behind the dialog
 *   maskZIndex  - Z-index of the background behind the dialog
 *   container   - Id or element to contain the dialog (defaults to body element)
 */
rdoc.CustomDialog = Class.create();
rdoc.CustomDialog.prototype = {
  /**
   * Constructor
   */
  baseInitialize: function(options) {
    this.options = {maskOpacity: 0.6, maskColor: '#000', maskZIndex: 1000};
    if (options) this.options = Object.extend(this.options, options);
    
    this.background = this.initBack();
    this.dialog = this.initDialog();
  },
  
  /**
   * Display the dialog
   */
  open: function(id) {
    var size = this.pageDimensions();
    
    this.background.style.top = '0px';
    this.background.style.left = '0px';
    this.background.style.width = size.width + 'px';
    this.background.style.height = size.height + 'px';
    if (this.options.maskOpacity) this.background.setOpacity(this.options.maskOpacity);
    jQuery(this.background).fadeIn('normal');
    
    this.centerDialog(size);
    jQuery(this.dialog).fadeIn('normal');
  },
  
  /**
   * Close/hide the dialog
   */
  close: function() {
    jQuery(this.background).fadeOut();
    jQuery(this.dialog).fadeOut();
  },
  
  /**
   * Center the dialog
   */
  centerDialog: function(size) {
    var scrollY = (window.scrollY ? window.scrollY : (document.body.scrollY ? document.body.scrollY : (document.documentElement.scrollTop ? document.documentElement.scrollTop : 0)));
    
    this.dialog.style.top = (scrollY + 40) + 'px';
    this.dialog.style.left = Math.floor((size.width - this.dialogWidth()) / 2) + 'px';
  },
  
  /**
   * Return the width of the dialog in pixels
   */
  dialogWidth: function() {
    return this.dialog.clientWidth;
  },
  
  /**
   * Create the background element
   */
  initBack: function() {
    var div = document.createElement('div');
    div.style.position = 'absolute';
    div.style.display = 'none';
    if (this.options.maskColor) div.style.backgroundColor = this.options.maskColor;
    if (this.options.maskZIndex) div.style.zIndex = this.options.maskZIndex;
    var container = this.options.container ? $(this.options.container) : $$('body').first();
    container.appendChild(div);
    return $(div);
  },
  
  /**
   * Create the dialog element
   */
  initDialog: function() {
    var div = document.createElement('div');
    div.style.position = 'absolute';
    div.style.display = 'none';
    if (this.options.maskZIndex) div.style.zIndex = this.options.maskZIndex + 1;
    var container = this.options.container ? $(this.options.container) : $$('body').first();
    container.appendChild(div);
    return $(div);
  },
  
  /**
   * Current scrollable size
   */
  scrollableDimensions: function() {
    var size = {};
    
    if (window.innerHeight && window.scrollMaxY) {
      var baseWidth = document.documentElement.clientWidth ? document.documentElement.clientWidth : window.innerWidth;
      size.width  = baseWidth + window.scrollMaxX;
      size.height = window.innerHeight + window.scrollMaxY;
    } else if (document.body.scrollHeight > document.body.offsetHeight){ // all but Explorer Mac
      size.width  = document.body.scrollWidth;
      size.height = document.body.scrollHeight;
    } else { // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
      size.width = document.body.offsetWidth;
      if (document.documentElement && document.documentElement.scrollHeight > document.body.offsetHeight)
        size.height = document.documentElement.scrollHeight;
      else
        size.height = document.body.offsetHeight;
    }
    
    return size;
  },
  
  /**
   * Current document size
   */
  documentDimensions: function() {
    var size = {};
    
    if (self.innerHeight) {	// all except Explorer
      size.width = document.documentElement.clientWidth ?
                    document.documentElement.clientWidth : self.innerWidth;
      size.height = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      if (document.body && document.body.clientWidth > document.documentElement.clientWidth)
        size.width = document.body.clientWidth;
      else
        size.width = document.documentElement.clientWidth;
      if (document.body && document.body.clientHeight > document.documentElement.clientHeight)
        size.height = document.body.clientHeight;
      else
        size.height = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      size.width = document.body.clientWidth;
      size.height = document.body.clientHeight;
    }

    return size;
  },
  
  /**
   * Determine the current page size
   */
  pageDimensions: function () {
    var scrollSize = this.scrollableDimensions();
    var winSize = this.documentDimensions();
    var pageSize = {};
   
    // for small pages with total height less then height of the viewport
    pageSize.height = (scrollSize.height < winSize.height) ? winSize.height : scrollSize.height;
    // for small pages with total width less then width of the viewport
    pageSize.width = (scrollSize.width < winSize.width) ? winSize.width : scrollSize.width;
  
    return pageSize;
  }
  
};
