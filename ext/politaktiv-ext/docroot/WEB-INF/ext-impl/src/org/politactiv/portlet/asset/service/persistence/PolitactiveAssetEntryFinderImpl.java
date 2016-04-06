package org.politactiv.portlet.asset.service.persistence;

import com.liferay.portal.kernel.dao.orm.*;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.CharPool;
import com.liferay.portal.kernel.util.StringBundler;
import com.liferay.portal.kernel.util.StringPool;
import com.liferay.portal.kernel.util.Validator;
import com.liferay.portal.model.Layout;
import com.liferay.portlet.asset.model.AssetEntry;
import com.liferay.portlet.asset.model.impl.AssetEntryImpl;
import com.liferay.portlet.asset.service.persistence.AssetEntryFinderImpl;
import com.liferay.portlet.asset.service.persistence.AssetEntryQuery;

import java.util.List;

public class PolitactiveAssetEntryFinderImpl
        extends AssetEntryFinderImpl
        implements PolitactiveAssetEntryFinder {

    private static Log _log = LogFactoryUtil.getLog(PolitactiveAssetEntryFinderImpl.class);




    @Override
    public List<AssetEntry> findEntries(AssetEntryQuery entryQuery)
            throws SystemException {

        Session session = null;

        try {
            session = openSession();

            SQLQuery q = buildAssetQuerySQL(entryQuery, false, session);

            return (List<AssetEntry>) QueryUtil.list(
                    q, getDialect(), entryQuery.getStart(), entryQuery.getEnd());
        }
        catch (Exception e) {
            throw new SystemException(e);
        }
        finally {
            closeSession(session);
        }
    }

    protected SQLQuery buildAssetQuerySQL(
            AssetEntryQuery entryQuery, boolean count, Session session)
            throws SystemException {

        StringBundler sb = new StringBundler();

        if (count) {
            sb.append(
                    "SELECT COUNT(DISTINCT AssetEntry.entryId) AS COUNT_VALUE ");
        }
        else {
            sb.append("SELECT DISTINCT {AssetEntry.*} ");

            String orderByCol1 = entryQuery.getOrderByCol1();
            String orderByCol2 = entryQuery.getOrderByCol2();

            if (orderByCol1.equals("ratings") ||
                    orderByCol2.equals("ratings")) {

                sb.append(", RatingsStats.averageScore ");
            }
        }

        sb.append("FROM AssetEntry ");

        if (entryQuery.getAnyTagIds().length > 0) {
            sb.append("INNER JOIN ");
            sb.append("AssetEntries_AssetTags ON ");
            sb.append("(AssetEntries_AssetTags.entryId = ");
            sb.append("AssetEntry.entryId) ");
            sb.append("INNER JOIN ");
            sb.append("AssetTag ON ");
            sb.append("(AssetTag.tagId = AssetEntries_AssetTags.tagId) ");
        }

        if (entryQuery.getLinkedAssetEntryId() > 0) {
            sb.append("INNER JOIN ");
            sb.append("AssetLink ON ");
            sb.append("(AssetEntry.entryId = AssetLink.entryId1) ");
            sb.append("OR (AssetEntry.entryId = AssetLink.entryId2)");
        }

        if (entryQuery.getOrderByCol1().equals("ratings") ||
                entryQuery.getOrderByCol2().equals("ratings")) {

            sb.append(" LEFT JOIN ");
            sb.append("RatingsStats ON ");
            sb.append("(RatingsStats.classNameId = ");
            sb.append("AssetEntry.classNameId) AND ");
            sb.append("(RatingsStats.classPK = AssetEntry.classPK)");
        }

        if(entryQuery.getOrderByCol1().equals("lastName")){
            sb.append(" LEFT JOIN ");
            sb.append("User_ ON ");
            sb.append("(User_.userId = ");
            sb.append("AssetEntry.userId)");
        }

        if(entryQuery.getOrderByCol1().startsWith("categoryName")){
            sb.append(" LEFT JOIN ");
            sb.append("AssetEntries_AssetCategories ON ");
            sb.append("(AssetEntries_AssetCategories.entryId = ");
            sb.append("AssetEntry.entryId)");

            sb.append(" LEFT JOIN ");
            sb.append("AssetCategory ON ");
            sb.append("(AssetCategory.categoryId = ");
            sb.append("AssetEntries_AssetCategories.categoryId) ");
            String vocabularyId = entryQuery.getOrderByCol1().replace("categoryName:", "");
            if(!vocabularyId.isEmpty()){
                sb.append(" AND (AssetCategory.vocabularyId = ");
                sb.append(vocabularyId);
                sb.append(") ");
            }
        }


        sb.append("WHERE ");

        int whereIndex = sb.index();

        if (entryQuery.getLinkedAssetEntryId() > 0) {
            sb.append(" AND ((AssetLink.entryId1 = ?) OR ");
            sb.append("(AssetLink.entryId2 = ?))");
            sb.append(" AND (AssetEntry.entryId != ?)");
        }

        if (entryQuery.isVisible() != null) {
            sb.append(" AND (visible = ?)");
        }

        if (entryQuery.isExcludeZeroViewCount()) {
            sb.append(" AND (AssetEntry.viewCount > 0)");
        }

        // Keywords

        if (Validator.isNotNull(entryQuery.getKeywords())) {
            sb.append(" AND ((AssetEntry.title LIKE ?) OR");
            sb.append(" (AssetEntry.description LIKE ?))");
        }
        else {
            if (Validator.isNotNull(entryQuery.getTitle())) {
                sb.append(" AND (AssetEntry.title LIKE ?)");
            }

            if (Validator.isNotNull(entryQuery.getDescription())) {
                sb.append(" AND (AssetEntry.description LIKE ?)");
            }
        }

        // Layout

        Layout layout = entryQuery.getLayout();

        if (layout != null) {
            sb.append(" AND (AssetEntry.layoutUuid = ?)");
        }

        // Category conditions

        if (entryQuery.getAllCategoryIds().length > 0) {
            buildAllCategoriesSQL(entryQuery.getAllCategoryIds(), sb);
        }

        if (entryQuery.getAnyCategoryIds().length > 0) {
            buildAnyCategoriesSQL(entryQuery.getAnyCategoryIds(), sb);
        }

        if (entryQuery.getNotAllCategoryIds().length > 0) {
            buildNotAllCategoriesSQL(entryQuery.getNotAllCategoryIds(), sb);
        }

        if (entryQuery.getNotAnyCategoryIds().length > 0) {
            buildNotAnyCategoriesSQL(entryQuery.getNotAnyCategoryIds(), sb);
        }

        // Asset entry subtypes

        if (entryQuery.getClassTypeIds().length > 0) {
            buildClassTypeIdsSQL(entryQuery.getClassTypeIds(), sb);
        }

        // Tag conditions

        if (entryQuery.getAllTagIds().length > 0) {
            buildAllTagsSQL(entryQuery.getAllTagIdsArray(), sb);
        }

        if (entryQuery.getAnyTagIds().length > 0) {
            buildAnyTagsSQL(entryQuery.getAnyTagIds(), sb);
        }

        if (entryQuery.getNotAllTagIds().length > 0) {
            buildNotAllTagsSQL(entryQuery.getNotAllTagIdsArray(), sb);
        }

        if (entryQuery.getNotAnyTagIds().length > 0) {
            buildNotAnyTagsSQL(entryQuery.getNotAnyTagIds(), sb);
        }

        // Other conditions

        sb.append(
                getDates(
                        entryQuery.getPublishDate(), entryQuery.getExpirationDate()));
        sb.append(getGroupIds(entryQuery.getGroupIds()));
        sb.append(getClassNameIds(entryQuery.getClassNameIds()));

        if (!count) {
            sb.append(" ORDER BY ");

            if (entryQuery.getOrderByCol1().equals("ratings")) {
                sb.append("RatingsStats.averageScore");
            }else if(entryQuery.getOrderByCol1().equals("lastName")){
                sb.append("User_.");
                sb.append(entryQuery.getOrderByCol1());
            }else if(entryQuery.getOrderByCol1().startsWith("categoryName")){
                sb.append("AssetCategory.name");
            }else {
                sb.append("AssetEntry.");
                sb.append(entryQuery.getOrderByCol1());
            }

            sb.append(StringPool.SPACE);
            sb.append(entryQuery.getOrderByType1());

            if (Validator.isNotNull(entryQuery.getOrderByCol2()) &&
                    !entryQuery.getOrderByCol1().equals(
                            entryQuery.getOrderByCol2())) {

                if (entryQuery.getOrderByCol2().equals("ratings")) {
                    sb.append(", RatingsStats.averageScore");
                }
                else {
                    sb.append(", AssetEntry.");
                    sb.append(entryQuery.getOrderByCol2());
                }

                sb.append(StringPool.SPACE);
                sb.append(entryQuery.getOrderByType2());
            }
        }

        if (sb.index() > whereIndex) {
            String where = sb.stringAt(whereIndex);

            if (where.startsWith(" AND")) {
                sb.setStringAt(where.substring(4), whereIndex);
            }
        }

        String sql = sb.toString();

        SQLQuery q = session.createSQLQuery(sql);

        if (count) {
            q.addScalar(COUNT_COLUMN_NAME, Type.LONG);
        }
        else {
            q.addEntity("AssetEntry", AssetEntryImpl.class);
        }

        QueryPos qPos = QueryPos.getInstance(q);

        if (entryQuery.getLinkedAssetEntryId() > 0) {
            qPos.add(entryQuery.getLinkedAssetEntryId());
            qPos.add(entryQuery.getLinkedAssetEntryId());
            qPos.add(entryQuery.getLinkedAssetEntryId());
        }

        if (entryQuery.isVisible() != null) {
            qPos.add(entryQuery.isVisible());
        }

        if (Validator.isNotNull(entryQuery.getKeywords())) {
            qPos.add(entryQuery.getKeywords() + CharPool.PERCENT);
            qPos.add(entryQuery.getKeywords() + CharPool.PERCENT);
        }
        else {
            if (Validator.isNotNull(entryQuery.getTitle())) {
                qPos.add(entryQuery.getTitle() + CharPool.PERCENT);
            }

            if (Validator.isNotNull(entryQuery.getDescription())) {
                qPos.add(entryQuery.getDescription() + CharPool.PERCENT);
            }
        }

        if (layout != null) {
            qPos.add(layout.getUuid());
        }

        setDates(
                qPos, entryQuery.getPublishDate(), entryQuery.getExpirationDate());

        qPos.add(entryQuery.getGroupIds());
        qPos.add(entryQuery.getClassNameIds());

        return q;
    }
}
