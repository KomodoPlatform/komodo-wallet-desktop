#include "modelhelper.h"
#include <QCoreApplication>
#include <QQmlInfo>
#include <QPersistentModelIndex>

class ModelHelperPropertyMap : public QQmlPropertyMap
{
  public:
    ModelHelperPropertyMap(int row, int column, const QModelIndex& parentIndex, QAbstractItemModel* model, QObject* parent = nullptr);

  protected:
    QVariant updateValue(const QString& key, const QVariant& input) override;

  private:
    QModelIndex modelIndex() const;

    void update();
    void onDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles);
    void onRowsInserted(const QModelIndex& parent, int first, int last);
    void onRowsRemoved(const QModelIndex& parent, int first, int last);
    void onColumnsInserted(const QModelIndex& parent, int first, int last);
    void onColumnsRemoved(const QModelIndex& parent, int first, int last);

    int m_row;
    int m_column;
    QPersistentModelIndex m_parent;
    QAbstractItemModel* m_model;
};

QVariant ModelHelperPropertyMap::updateValue(const QString& key, const QVariant& input)
{
    int role = m_model->roleNames().key(key.toUtf8(), -1);
    if (role == -1)
        return input;

    QModelIndex index = modelIndex();
    m_model->setData(index, input, role);
    return m_model->data(index, role);
}

ModelHelperPropertyMap::ModelHelperPropertyMap(int row, int column, const QModelIndex& parentIndex, QAbstractItemModel* model, QObject* parent) :
    QQmlPropertyMap(parent),
    m_row(row),
    m_column(column),
    m_parent(parentIndex),
    m_model(model)
{
    connect(model, &QAbstractItemModel::modelReset, this, &ModelHelperPropertyMap::update);
    connect(model, &QAbstractItemModel::layoutChanged, this, &ModelHelperPropertyMap::update);
    connect(model, &QAbstractItemModel::dataChanged, this, &ModelHelperPropertyMap::onDataChanged);
    connect(model, &QAbstractItemModel::rowsInserted, this, &ModelHelperPropertyMap::onRowsInserted);
    connect(model, &QAbstractItemModel::rowsRemoved, this, &ModelHelperPropertyMap::onRowsRemoved);
    connect(model, &QAbstractItemModel::columnsInserted, this, &ModelHelperPropertyMap::onColumnsInserted);
    connect(model, &QAbstractItemModel::columnsInserted, this, &ModelHelperPropertyMap::onColumnsRemoved);
    update();
}

QModelIndex ModelHelperPropertyMap::modelIndex() const
{
    return m_model->index(m_row, m_column, m_parent);
}

void ModelHelperPropertyMap::update()
{
    QHash<int, QByteArray> roles = m_model->roleNames();
    QModelIndex index(modelIndex());
    for (auto it = roles.cbegin(); it != roles.cend(); ++it)
        insert(it.value(), m_model->data(index, it.key()));
}

void ModelHelperPropertyMap::onDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int> &roles)
{
    QModelIndex index(modelIndex());
    if (m_parent != topLeft.parent() || m_parent != bottomRight.parent())
        return;

    if (m_row >= topLeft.row() && m_column >= topLeft.column() && m_row <= bottomRight.row() && m_column <= bottomRight.column()) {
        auto roleNames = m_model->roleNames();
        QVector<int> actualRoles = roles.isEmpty() ? roleNames.keys().toVector() : roles;

        for (int role : actualRoles)
            insert(roleNames[role], m_model->data(index, role));
    }
}

void ModelHelperPropertyMap::onRowsInserted(const QModelIndex& parent, int first, int last)
{
    Q_UNUSED(last)
    if (parent == m_parent && m_row >= first)
        update();
}

void ModelHelperPropertyMap::onRowsRemoved(const QModelIndex& parent, int first, int last)
{
    Q_UNUSED(last)
    if (parent == m_parent && m_row >= first)
        update();
}

void ModelHelperPropertyMap::onColumnsInserted(const QModelIndex& parent, int first, int last)
{
    Q_UNUSED(last)
    if (parent == m_parent && m_column >= first)
        update();
}

void ModelHelperPropertyMap::onColumnsRemoved(const QModelIndex& parent, int first, int last)
{
    Q_UNUSED(last)
    if (parent == m_parent && m_column >= first)
        update();
}

ModelHelper::ModelHelper(QObject* object) : QObject(object)
{
    QAbstractItemModel* model = qobject_cast<QAbstractItemModel*>(object);
    if (!model)
        qmlInfo(object) << "ModelHelper must be attached to a QAbstractItemModel";
    else {
        m_model = model;

        connect(model, &QAbstractItemModel::rowsInserted, this, &ModelHelper::rowCountChanged);
        connect(model, &QAbstractItemModel::rowsRemoved, this, &ModelHelper::rowCountChanged);
        connect(model, &QAbstractItemModel::modelReset, this, &ModelHelper::rowCountChanged);
        connect(model, &QAbstractItemModel::layoutChanged, this, &ModelHelper::rowCountChanged);

        connect(model, &QAbstractItemModel::columnsInserted, this, &ModelHelper::columnCountChanged);
        connect(model, &QAbstractItemModel::columnsRemoved, this, &ModelHelper::columnCountChanged);
        connect(model, &QAbstractItemModel::modelReset, this, &ModelHelper::columnCountChanged);
        connect(model, &QAbstractItemModel::layoutChanged, this, &ModelHelper::columnCountChanged);

        connect(model, &QAbstractItemModel::modelReset, this, &ModelHelper::rolesChanged);
        connect(model, &QAbstractItemModel::layoutChanged, this, &ModelHelper::rolesChanged);

        if (model->roleNames().isEmpty())
            connect(model, &QAbstractItemModel::rowsInserted, this, &ModelHelper::updateRolesFix);
    }
}

ModelHelper* ModelHelper::qmlAttachedProperties(QObject* object)
{
    return new ModelHelper(object);
}

int ModelHelper::rowCount() const
{
    return m_model ? m_model->rowCount() : 0;
}

int ModelHelper::columnCount() const
{
    return m_model ? m_model->columnCount() : 0;
}

QVariantList ModelHelper::roles() const
{
    if (!m_model)
        return QVariantList{};

    QVariantList roles;
    QHash<int, QByteArray> roleNames = m_model->roleNames();
    for (auto it = roleNames.cbegin(); it != roleNames.cend(); ++it) {
        QVariantMap role = {{"role", it.key()}, {"roleName", QString::fromUtf8(it.value())}};
        roles.append(role);
    }
    return roles;
}

QQmlPropertyMap* ModelHelper::map(int row, int column, const QModelIndex& parent)
{
    if (!m_model)
        return nullptr;

    if (column == 0 && !parent.isValid()) {
        QQmlPropertyMap* mapper = mapperForRow(row);
        if (!mapper) {
            mapper = new ModelHelperPropertyMap(row, 0, {}, m_model, this);
            m_mappers.append({row, mapper});
            connect(mapper, &QObject::destroyed, this, &ModelHelper::removeMapper);
        }
        return mapper;
    }

    return new ModelHelperPropertyMap(row, column, parent, m_model, this);
}

int ModelHelper::roleForName(const QString &roleName) const
{
    if (!m_model)
        return -1;

    return m_model->roleNames().key(roleName.toUtf8(), -1);
}

QVariantMap ModelHelper::data(int row) const
{
    if (!m_model)
        return QVariantMap{};

    QVariantMap map;
    QModelIndex modelIndex = m_model->index(row, 0);
    QHash<int, QByteArray> roles = m_model->roleNames();
    for (auto it = roles.begin(); it != roles.end(); ++it)
        map.insert(it.value(), m_model->data(modelIndex, it.key()));
    return map;
}

QVariant ModelHelper::data(int row, const QString& roleName) const
{
    if (!m_model)
        return QVariant{};

    return m_model->data(m_model->index(row, 0), roleForName(roleName));
}

void ModelHelper::updateRolesFix()
{
    disconnect(m_model, &QAbstractItemModel::rowsInserted, this, &ModelHelper::updateRolesFix);
    Q_EMIT rolesChanged();
}

QQmlPropertyMap* ModelHelper::mapperForRow(int row) const
{
    auto it = std::find_if(
        m_mappers.begin(),
        m_mappers.end(),
        [row] (const QPair<int, QQmlPropertyMap*> pair) {
          return pair.first == row;
        });

    if (it != m_mappers.end())
        return it->second;
    else
        return nullptr;
}

void ModelHelper::removeMapper(QObject* mapper)
{
    auto it = std::find_if(
        m_mappers.begin(),
        m_mappers.end(),
        [mapper] (const QPair<int, QQmlPropertyMap*> pair) {
          return pair.second == mapper;
        });

    if (it != m_mappers.end())
        m_mappers.erase(it);
}

void registerModelHelperTypes() {
    qmlRegisterAnonymousType<QQmlPropertyMap>("", 1);
    qmlRegisterUncreatableType<ModelHelper>("ModelHelper", 0, 1, "ModelHelper", "ModelHelper is only available via attached properties");
}

Q_COREAPP_STARTUP_FUNCTION(registerModelHelperTypes)
