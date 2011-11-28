$("html").addClass $.client.os
uml = $.jumly
diagram = uml(".sequence-diagram")
            .append(osgi      = uml ".object", "&lt;&lt;interface>><br/>OSGi Framework::BundleContext")
            .append(dspcompo  = uml ".object", "&lt;&lt;interface>> dsp::DSPComponent")
            .append(activator = uml(".object", "platform::Activator").offset left:550)
osgi.activate()
    .interact(activator).name("start(BundleContext)").reply()
    .forward().create(name:"osgi::DSPBundleController", id:"dspbundle").name("DSPBundleController(installPath, bundleContext)")
    .awayfrom().create(id:"platform", name:"platform::Platform").name("Platform(installPath, bundleContext)").taking((e) -> e.css "margin-top":-32)
    .interact(diagram.platform).name("init()")
        .forward().create(id:"matcher", name:"matcher::Matcher").name("Matcher()")
        .awayfrom().interact(diagram.matcher).name('initComponent("Matcher", context)')
        .awayfrom().create(id:"msgbroker", name:"broker::MessageBroker").name('MessageBroker(Matcher)')
        .awayfrom().create(id:"compomgr", name:"component::ComponentManager").name('ComponentManager()')
        .awayfrom().interact(diagram.compomgr).name("init(contxtFactory, installHome)")
            .forward().create(id:"bootstrap", name:"component::BootstrapConfigurator").name("BootstrapConfigurator(installPath)")
                .forward().interact(diagram.bootstrap).name("loadBootstrapMessages()")
    .awayfrom(activator).interact(diagram.platform).name("start()").reply()  ## POINT: can't reply to osgi directly.
        .forward().interact(diagram.msgbroker).name("start()")
        .interact(diagram.compomgr).name("start()")
            .forward().interact(diagram.dspbundle).name("start()")
                .forward().interact(diagram.dspbundle).name("initDSPComponents()")
                    .forward().interact(diagram.dspbundle).name("readConfiguration(String)")
                    .interact(diagram.dspbundle).name("installBundles(Document)").attr("id", "loop-0")
                        .forward().interact(diagram.dspbundle).name("installBundle(bundleContext, bundleFileName):Bundle")
                        # I wanted .destroy ... ## POINT: can't destroy at hopeful occurrence.

dspbundle = diagram.dspbundle
async = dspbundle.activate()
         .interact(dspbundle).name("serviceChanged(ServiceEvent)").stereotype("asynchronous")
         ## POINT: Asynchronous self-calling.
dspbundle.activate()
         .interact(osgi).name("service=getService(event.getServiceReference()):Object")
         .interact(dspbundle).name("[service instanceof DSPComponent]:addComponent(String, DSPComponent)")
         .forward().interact(diagram.compomgr).name("attach(componentName, (DSPComponent)service)")
         .forward().interact(dspcompo).name("initComponent(component.getComponentNodeId(), context)")
         .interact(diagram.msgbroker).name("attach(component)")
         .interact(dspcompo).name("startComponent()")
         .awayfrom().interact(diagram.compomgr).name("sendBootstrapMessages(component)")
         .awayfrom().interact(diagram.bootstrap).name("updateMessages=createMessages(this, component.getComponentNodeId()):List&lt;Messages>")
         .parents(".occurrence").data("uml:this")  ## POINT: Traversal is poor.
            .interact(diagram.msgbroker).name("getMessageBrokerAccessor():MessageBrokerAccessor").attr("id", "loop-1")
         .forward().interact(diagram.msgbroker).name("send(UpdateMessage)")

loop0 = diagram.find("#loop-0").data("uml:this")
       .fragment "name":"Loop bundles Configuration", "condition":"[bundleFilesList.size()]"
loop1 = diagram.find("#loop-1").data("uml:this")
       .fragment "name":"Loop bootstrapMessages", "condition":"[bootstrapMessages.size()]"

d = diagram
diagram.dspbundle.offset left:800
diagram.platform .offset left:200
diagram.matcher  .offset left:320
diagram.msgbroker.offset left:640
diagram.compomgr .offset left:400
diagram.bootstrap.offset left:740

diagram.appendTo $ "body"
diagram.compose()
       .css("margin-bottom", "32em")

loop0.extendWidth left:300, right:80
loop1.extendWidth left:200, right:80
async.find("> .occurrence").hide()

