
"using strict";
var hideInputCellExtension = (function(){
    var Pos = CodeMirror.Pos;

    // What text to show for hidden cell.s
    var createHiding = function() {
        var hiding = document.createElement("span");
        hiding.innerHTML = "…";
        return hiding;
    }

    // What to show on button when concealed or shown.
    var concealedButton = "⇨";
    var shownButton = "⇩";

    // UI Generator for a simple toggle button.
    IPython.CellToolbar.utils.button_ui_generator = function(name, handler, textfun){
        return function(div, cell, celltoolbar) {
            var button_container = $(div);
            var initText = textfun(cell);

            var button = $('<input/>').attr('type', 'button')
                                      .attr('value', initText)
                                      .css('height', '1.1em')
                                      .css('font-size', 20);
            var lbl = $('<label/>').append($('<span/>').text(name));
            lbl.append(button);
            button.click(function() { 
                handler(cell);
                var newText = textfun(cell);
                button.attr('value', newText);
            });
            button_container.append($('<div/>').append(lbl));
        };
    };

    console.log("Our extension was loaded successfully");
    // Create and register the method that creates the hide arrow.
    var flag_name = 'hide_input';
    var cell_flag_init = IPython.CellToolbar.utils.button_ui_generator("", function(cell) {
        cell.metadata.hidden = !cell.metadata.hidden;
        updateCellVisibility(cell);
    }, function(cell){
        if(cell.metadata.hidden) {
            return concealedButton;
        } else {
            return shownButton;
        };
    });

    var updateCellVisibility = function(cell) {
        if(cell.metadata.hidden) {
            var editor = cell.code_mirror;
            var nLines = editor.lineCount();
            var firstLineLen = editor.getLine(0).length;
            var lastLineLen = editor.getLine(nLines - 1).length;
            var mark = editor.markText(Pos(0, firstLineLen), Pos(nLines, lastLineLen + 1), {
                replacedWith: createHiding(),
            });
            cell.mark = mark;
        } else if (cell.mark !== undefined) {
            cell.mark.clear();
        }
    }

    IPython.CellToolbar.register_callback(flag_name, cell_flag_init);

    // Create and register the toolbar with IPython.
    IPython.CellToolbar.register_preset('Hiding', [flag_name]);
    

    var createCell = function(cell) {
        cell.metadata.hidden = false;
        console.log('Cell created, initially unhidden');
    }

    var initExtension = function(event) {
        IPython.CellToolbar.activate_preset("Hiding");

        var cells = IPython.notebook.get_cells();
        for(var i in cells){
            var cell = cells[i];
            if ((cell instanceof IPython.CodeCell)) {
                updateCellVisibility(cell);
            }
        }

        $([IPython.events]).on('create.Cell',createCell);
    }

    require([], initExtension);

})();
