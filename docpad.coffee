# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
path = require('path')
fs = require('fs')
util = require('util')
docpadConfig = {

    # =================================
    # Template Data
    # These are variables that will be accessible via our templates
    # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

    templateData:

        # Specify some site properties
        site:
            # The production url of our website
            url: "http://docpad-api.herokuapp.com"

            # Here are some old site urls that you would like to redirect from
            oldUrls: []

            # The default title of our website
            title: "Docpad API"

            # The website description (for SEO)
            description: """
                Docpad API documentation site.
                """

            # The website keywords (for SEO) separated by commas
            keywords: """
                docpad, documantation, node, node.js, nodejs, javascript, coffeescript, web development
                """
            styles: [
                '/css/foundation.css'
                '/css/base.css'
                '/css/header.css'
                '/css/icon-fonts.css'
                '/css/hover.css'
                '/css/footer-bottom.css'
                '/css/black-tie/jquery-ui.css'
                '/js/jstree/themes/default/style.css'
                '/fonts/css/font-awesome.css'
                'css/tabs-tree.css'
                'css/style.css'
            ]

            # The website's styles
            combinedStyles: [
                '/css/main-min.css'
                'css/black-tie/jquery-ui.css'
                'js/jstree/themes/default/style.css'
                'fonts/css/font-awesome.css'
                'css/tabs-tree.css'
                'css/style.css'
            ]

            # The website's scripts
            scripts: [
                '/js/jquery.js'
                'js/foundation-min.js'
                '/js/jquery-ui/jquery-ui.js'
                '/js/jstree/jstree.js'
                '/js/marked.js'
                '/js/doc-tree.js'
            ]

            thisYear: (new Date()).getFullYear()


        # -----------------------------
        # Helper Functions

        # Get the prepared site/document title
        # Often we would like to specify particular formatting to our page's title
        # we can apply that formatting here
        getPreparedTitle: ->
            # if we have a document title, then we should use that and suffix the site's title onto it
            if @document.title
                "#{@document.title}"
            # if our document does not have it's own title, then we should just use the site's title
            else
                @site.title

        # Get the prepared site/document description
        getPreparedDescription: ->
            # if we have a document description, then we should use that, otherwise use the site's description
            @document.description or @site.description

        # Get the prepared site/document keywords
        getPreparedKeywords: ->
            # Merge the document keywords with the site keywords
            @site.keywords.concat(@document.keywords or []).join(', ')


    # Collections

    collections:

        cssFiles: ->
            items = @getCollection('files').findAllLive({relativeDirPath:'css'})
            return items;


    # =================================
    # Environments

    # DocPad's default environment is the production environment
    # The development environment, actually extends from the production environment

    # The following overrides our production url in our development environment with false
    # This allows DocPad's to use it's own calculated site URL instead, due to the falsey value
    # This allows <%- @site.url %> in our template data to work correctly, regardless what environment we are in
    env: 'production'

    environments:
        development:  # default
            # Always refresh from server
            maxAge: false  # default

        production:
            maxAge: false
            # maxAge: false

        static:
            maxAge: 86400000
            # maxAge: false


    # =================================
    # DocPad Events

    # Here we can define handlers for events that DocPad fires
    # You can find a full listing of events on the DocPad Wiki
    events:

        # Server Extend
        # Used to add our own custom routes to the server before the docpad routes are added
        serverExtend: (opts) ->
            # Extract the server from the options
            {server} = opts
            docpad = @docpad

            # As we are now running in an event,
            # ensure we are using the latest copy of the docpad configuraiton
            # and fetch our urls from it
            latestConfig = docpad.getConfig()
            oldUrls = latestConfig.templateData.site.oldUrls or []
            newUrl = latestConfig.templateData.site.url

            # Redirect any requests accessing one of our sites oldUrls to the new site url
            server.use (req,res,next) ->

                if req.headers.host in oldUrls
                    res.redirect(newUrl+req.url, 301)
                else
                    next()

#        #flip to uncombined styles in development
#        docpadLoaded: (opts) ->
#            tmplData = @docpad.getTemplateData()
#            env = tmplData.getEnvironment()
#            if env == "development"
#                tmplData.site.styles =  tmplData.site.devStyles
#
#            #Chain
#            @
}

# Export our DocPad Configuration
module.exports = docpadConfig
