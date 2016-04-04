package org.politactiv.hook;


import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portlet.asset.model.AssetEntry;
import com.liferay.portlet.asset.service.AssetEntryLocalService;
import com.liferay.portlet.asset.service.AssetEntryLocalServiceWrapper;
import com.liferay.portlet.asset.service.persistence.AssetEntryQuery;

import java.util.List;

/**
 * @author Nikoly Ukraintsev created on 3/30/16.
 *         email nikolay.ukrajncev@kruschecompany.com
 */
public class PolitactiveAssetEntryLocalServiceImpl extends AssetEntryLocalServiceWrapper {

    public PolitactiveAssetEntryLocalServiceImpl(AssetEntryLocalService assetEntryLocalService) {
        super(assetEntryLocalService);
    }

    @Override
    public List<AssetEntry> getEntries(AssetEntryQuery entryQuery)
            throws SystemException {

        return  super.getEntries(entryQuery);
    }


    @Override
    public int getEntriesCount(AssetEntryQuery entryQuery) throws SystemException {

        return super.getEntriesCount(entryQuery);
    }

}
