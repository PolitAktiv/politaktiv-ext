package org.politactiv.portlet.asset.service.persistence;

import com.liferay.portlet.asset.service.persistence.AssetEntryQuery;

/**
 * @author Nikoly Ukraintsev created on 3/31/16.
 *         email nikolay.ukrajncev@kruschecompany.com
 */
public class PolitactiveAssetEntryQuery extends AssetEntryQuery {


    public PolitactiveAssetEntryQuery() {
        super();
    }

    public PolitactiveAssetEntryQuery(AssetEntryQuery entryQuery) {
        super(entryQuery);
    }

    private String customeOrderBy;

    @Override
    public void setOrderByCol1(String orderByCol1) {
        customeOrderBy = orderByCol1;
    }

    @Override
    public String getOrderByCol1() {
        return customeOrderBy;
    }
}
