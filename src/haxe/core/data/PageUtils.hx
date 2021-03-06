package core.data;

import js.lib.Promise;
import core.data.utils.PromiseUtils;

class PageUtils {
    public function new() {
    }

    public function page(pageId:Int):PageData {
        var page = null;
        for (p in InternalDB.pages.data) {
            if (p.pageId == pageId) {
                page = p;
                break;
            }
        }
        return page;
    }

    public function sitePages(siteId:Int, parentPageId:Null<Int> = null):Array<PageData> {
        var list = [];

        for (page in InternalDB.pages.data) {
            if (page.siteId != siteId) {
                continue;
            }
            if (parentPageId != null && page.parentPageId == parentPageId) {
                list.push(page);
            } else if (parentPageId == null) {
                list.push(page);
            }
        }

        return list;
    }


    public function portletInstances(pageId:Int):Array<PortletInstanceData> {
        var instances = [];

        for (portletInstance in InternalDB.portletInstances.data) {
            if (portletInstance.pageId == pageId) {
                instances.push(portletInstance);
            }
        }

        return instances;
    }

    public function assignPortletInstances(pageId, portletInstances:Array<PortletInstanceData>, removeExisting:Bool = true):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [];
            for (portletInstance in portletInstances) {
                portletInstance.pageId = pageId;
                promises.push(InternalDB.portletInstances.addObject(portletInstance));
            }

            if (removeExisting) {
                removeAllPortletInstances(pageId).then(function(r) {
                    PromiseUtils.runSequentially(promises, function() {
                        resolve(true);
                    });
                });
            } else {
                PromiseUtils.runSequentially(promises, function() {
                    resolve(true);
                });
            }
        });
    }

    public function removeAllPortletInstances(pageId:Int):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var promises = [];

            for (portletInstance in portletInstances(pageId)) {
                promises.push(InternalDB.portletInstances.removeObject(portletInstance));
            }

            PromiseUtils.runSequentially(promises, function() {
                resolve(true);
            });
        });
    }
}