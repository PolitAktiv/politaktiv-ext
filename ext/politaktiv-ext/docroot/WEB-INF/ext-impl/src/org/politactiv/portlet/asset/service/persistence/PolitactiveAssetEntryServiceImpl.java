package org.politactiv.portlet.asset.service.persistence;

import com.liferay.portal.kernel.cache.Lifecycle;
import com.liferay.portal.kernel.cache.ThreadLocalCache;
import com.liferay.portal.kernel.cache.ThreadLocalCacheManager;
import com.liferay.portal.kernel.dao.orm.QueryUtil;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.security.permission.ActionKeys;
import com.liferay.portal.security.permission.PermissionChecker;
import com.liferay.portal.util.PropsValues;
import com.liferay.portlet.asset.AssetRendererFactoryRegistryUtil;
import com.liferay.portlet.asset.model.AssetEntry;
import com.liferay.portlet.asset.model.AssetRendererFactory;
import com.liferay.portlet.asset.service.impl.AssetEntryServiceImpl;
import com.liferay.portlet.asset.service.persistence.AssetEntryQuery;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Nikoly Ukraintsev created on 4/1/16.
 *         email nikolay.ukrajncev@kruschecompany.com
 */
public class PolitactiveAssetEntryServiceImpl extends AssetEntryServiceImpl {

    private static Log _log = LogFactoryUtil.getLog(PolitactiveAssetEntryServiceImpl.class);

    @Override
    public int getEntriesCount(AssetEntryQuery entryQuery)
            throws PortalException, SystemException {

        _log.error("Hello from sericeImpl1 get count="+entryQuery.getOrderByCol1());

        AssetEntryQuery filteredEntryQuery = buildFilteredEntryQuery(
                entryQuery);

        if (hasEntryQueryResults(entryQuery, filteredEntryQuery)) {
            return 0;
        }
        String key = entryQuery.toString();

        key = key.concat(StringPool.POUND).concat(
                Boolean.toString(true));

        ThreadLocalCache<Object[]> threadLocalCache =
                ThreadLocalCacheManager.getThreadLocalCache(
                        Lifecycle.REQUEST, AssetEntryServiceImpl.class.getName());


        Object[] results = threadLocalCache.get(key);

        if (results != null) {
            return (Integer)results[1];
        }

        if (true && !entryQuery.isEnablePermissions()) {
            int entriesCount = assetEntryLocalService.getEntriesCount(
                    entryQuery);

            results = new Object[] {null, entriesCount};

            threadLocalCache.put(key, results);

            return (Integer)results[1];
        }

        int end = entryQuery.getEnd();
        int start = entryQuery.getStart();

        if (entryQuery.isEnablePermissions()) {
            entryQuery.setEnd(end + PropsValues.ASSET_FILTER_SEARCH_LIMIT);
            entryQuery.setStart(0);
        }

        List<AssetEntry> entries = assetEntryLocalService.getEntries(
                entryQuery);

        List<AssetEntry> filteredEntries = null;
        int filteredEntriesCount = 0;

        if (entryQuery.isEnablePermissions()) {
            PermissionChecker permissionChecker = getPermissionChecker();

            filteredEntries = new ArrayList<AssetEntry>();

            for (AssetEntry entry : entries) {
                String className = entry.getClassName();
                long classPK = entry.getClassPK();

                AssetRendererFactory assetRendererFactory =
                        AssetRendererFactoryRegistryUtil.
                                getAssetRendererFactoryByClassName(className);

                try {
                    if (assetRendererFactory.hasPermission(
                            permissionChecker, classPK, ActionKeys.VIEW)) {

                        filteredEntries.add(entry);
                    }
                }
                catch (Exception e) {
                }

                if ((end != QueryUtil.ALL_POS) &&
                        (filteredEntries.size() > end)) {

                    break;
                }
            }

            filteredEntriesCount = filteredEntries.size();

            if ((end != QueryUtil.ALL_POS) && (start != QueryUtil.ALL_POS)) {
                if (end > filteredEntriesCount) {
                    end = filteredEntriesCount;
                }

                if (start > filteredEntriesCount) {
                    start = filteredEntriesCount;
                }

                filteredEntries = filteredEntries.subList(start, end);
            }

            entryQuery.setEnd(end);
            entryQuery.setStart(start);
        }
        else {
            filteredEntries = entries;
            filteredEntriesCount = filteredEntries.size();
        }

        results = new Object[] {filteredEntries, filteredEntriesCount};

        threadLocalCache.put(key, results);

        return (Integer)results[1];

    }




    @Override
    public List<AssetEntry> getEntries(AssetEntryQuery entryQuery)
    throws PortalException, SystemException {

        _log.error("Hello from sericeImpl2 get Entries="+entryQuery.getOrderByCol1());
        AssetEntryQuery filteredEntryQuery = buildFilteredEntryQuery(
                entryQuery);

        if (hasEntryQueryResults(entryQuery, filteredEntryQuery)) {
            return new ArrayList<AssetEntry>();
        }

        ThreadLocalCache<Object[]> threadLocalCache =
                ThreadLocalCacheManager.getThreadLocalCache(
                        Lifecycle.REQUEST, AssetEntryServiceImpl.class.getName());

        String key = entryQuery.toString();

        key = key.concat(StringPool.POUND).concat(
                Boolean.toString(false));

        Object[] results = threadLocalCache.get(key);

        if (results != null) {
            return (List<AssetEntry>)results[0];
        }

        if (false && !entryQuery.isEnablePermissions()) {
            int entriesCount = assetEntryLocalService.getEntriesCount(
                    entryQuery);

            results = new Object[] {null, entriesCount};

            threadLocalCache.put(key, results);

            return (List<AssetEntry>)results[0];
        }

        int end = entryQuery.getEnd();
        int start = entryQuery.getStart();

        if (entryQuery.isEnablePermissions()) {
            entryQuery.setEnd(end + PropsValues.ASSET_FILTER_SEARCH_LIMIT);
            entryQuery.setStart(0);
        }

        List<AssetEntry> entries = assetEntryLocalService.getEntries(
                entryQuery);

        List<AssetEntry> filteredEntries = null;
        int filteredEntriesCount = 0;

        if (entryQuery.isEnablePermissions()) {
            PermissionChecker permissionChecker = getPermissionChecker();

            filteredEntries = new ArrayList<AssetEntry>();

            for (AssetEntry entry : entries) {
                String className = entry.getClassName();
                long classPK = entry.getClassPK();

                AssetRendererFactory assetRendererFactory =
                        AssetRendererFactoryRegistryUtil.
                                getAssetRendererFactoryByClassName(className);

                try {
                    if (assetRendererFactory.hasPermission(
                            permissionChecker, classPK, ActionKeys.VIEW)) {

                        filteredEntries.add(entry);
                    }
                }
                catch (Exception e) {
                }

                if ((end != QueryUtil.ALL_POS) &&
                        (filteredEntries.size() > end)) {

                    break;
                }
            }

            filteredEntriesCount = filteredEntries.size();

            if ((end != QueryUtil.ALL_POS) && (start != QueryUtil.ALL_POS)) {
                if (end > filteredEntriesCount) {
                    end = filteredEntriesCount;
                }

                if (start > filteredEntriesCount) {
                    start = filteredEntriesCount;
                }

                filteredEntries = filteredEntries.subList(start, end);
            }

            entryQuery.setEnd(end);
            entryQuery.setStart(start);
        }
        else {
            filteredEntries = entries;
            filteredEntriesCount = filteredEntries.size();
        }

        results = new Object[] {filteredEntries, filteredEntriesCount};

        threadLocalCache.put(key, results);

        return (List<AssetEntry>)results[0];
    }

}
