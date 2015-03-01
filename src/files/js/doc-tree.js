/*global $, marked, setTimeout*/
$(function () {
    var tabs = $("#tabs").tabs();



    $('#tree-container').jstree({
        'core': {
            'data': {
                "url": function (node) {
                    if (node.id === "#") {
                        return "docs/class-list.json";
                    } else if (node.original.file) {
                        return "docs/" + node.original.file;
                    }
                }

            }
        },
        "plugins": ["search", "sort"]
    });


    // close icon: removing the tab on click
    tabs.delegate("span.ui-icon-close", "click", function () {
        var panelId = $(this).closest("li").remove().attr("aria-controls");
        $("#" + panelId).remove();
        tabs.tabs("refresh");
    });

    function getHtml(cfg, parent) {
        var title = (parent.text) ? parent.text + "." + cfg.text : cfg.text;
        var tmp = '<div style="display:none;" id="node' + cfg.id + '" class="member"><h4>' + title + '</h4>';
        if (cfg.comments) {
            tmp += '<div>';
            var txt = "";
            for (var i = 0; i < cfg.comments.length; i++) {
                txt += cfg.comments[i].trim() + "<br>";
            }
            txt = marked(txt);
            tmp += txt + '</div>';
        }
        if(parent.text === "Events"){
           var el = $('.panel #-'+cfg.text.toLowerCase()+'-');
            if (el.length > 0){
               el = el.parent();
                tmp += el.html();
            }
        }

        if (cfg.code.length > 0) {
            tmp += '<div class="code-title">Internal Code:</div>';
            tmp += '<pre>';
            for (var i = 0; i < cfg.code.length; i++) {
                var span = '<span>';
                if (cfg.code[i].trim().substr(0, 1) === '#') {
                    span = '<span class="comment">';
                }
                tmp += span + cfg.code[i].replace(/\t\t/g, "    ") + "</span>\n";

            }
            tmp += '</pre>';
        }

        tmp += '</div>';
        return tmp;
    }

    function getAllContent(tree, parent) {
        var html = "";
        for (var i = 0; i < parent.children.length; i++) {
            var child = tree.get_node(parent.children[i]);
            var cfg = child.original;
            html += getHtml(cfg, parent);
        }
        return html;

    }


    var tabCount = 2;

    $('#tree-container').on("select_node.jstree", function (e, selected) {
        var tab = $('#tabs-1 .tab-content');
        var node = selected.node;
        var tree = selected.instance;
        var parent = tree.get_node(node.parent);

        if (parent.id === 'root') {

            var openTab = function (theNode) {
                var config = theNode.original;
                var tabs = $('#tabs');
                var existTab = $("#tab-list a[data-text='" + theNode.text + "']");
                if (existTab.length === 0) {
                    $("#tab-list").append('<li><a data-text="' + theNode.text + '" href="#tabs-' + tabCount + '">' + theNode.text +
                        '</a><span class="ui-icon ui-icon-close" role="presentation">Remove Tab</span></li>');
                    tabs.append("<div id='tabs-" + tabCount + "'> <div class='tab-content'>" + config.file + "</div></div>");
                    tabs.tabs("refresh");
                    tabs.tabs("option", "active", tabCount - 1);
                    var pageHtml = getAllContent(tree, theNode);
                    var el = $('#tabs-' + tabCount + ' .tab-content');
                    el.html(pageHtml);
                    el.children().slideDown(600);
                    tabCount++;

                } else {
                    existTab.trigger('click');
                }
            };
            if (node.children.length === 0) {
                var dothis = function(){
                    var theNode = tree.get_node(node.id);
                    openTab(theNode);
                };
                tree.open_node(node, dothis);
            } else {
                openTab(node);
            }
        } else {
            var haveTab = $('#node' + node.id);
            if (haveTab.length === 0) {
                var config = node.original;
                var html = getHtml(config, parent);
                $('body').append(html);
                haveTab = $('#node' + node.id);
            }
            $('#tabs').tabs("option", "active", 0);
            haveTab.fadeOut(200, function () {
                tab.prepend(haveTab);
                haveTab.slideDown();
            });

        }

    });




});
