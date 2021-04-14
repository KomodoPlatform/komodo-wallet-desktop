#ifndef MODELHELPER_H
#define MODELHELPER_H

#include <QObject>
#include <QAbstractItemModel>
#include <qqml.h>
#include <QQmlPropertyMap>

class ModelHelper : public QObject
{
  Q_OBJECT
    Q_PROPERTY(int rowCount READ rowCount NOTIFY rowCountChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY rowCountChanged)
    Q_PROPERTY(int columnCount READ columnCount NOTIFY columnCountChanged)
    Q_PROPERTY(QVariantList roles READ roles NOTIFY rolesChanged)

  public:
    explicit ModelHelper(QObject* object = nullptr);
    static ModelHelper* qmlAttachedProperties(QObject* object);

    int rowCount() const;
    int columnCount() const;
    QVariantList roles() const;

    Q_INVOKABLE QQmlPropertyMap* map(int row, int column = 0, const QModelIndex& parent = {});

    Q_INVOKABLE int roleForName(const QString& roleName) const;

    Q_INVOKABLE QVariantMap data(int row) const;
    Q_INVOKABLE QVariant data(int row, const QString& roleName) const;

  Q_SIGNALS:
    void rowCountChanged();
    void columnCountChanged();
    void rolesChanged();

  private:
    void updateRolesFix();
    QQmlPropertyMap* mapperForRow(int row) const;
    void removeMapper(QObject* mapper);

    QAbstractItemModel* m_model = nullptr;
    int m_columnCount;
    QVector<QPair<int, QQmlPropertyMap*>> m_mappers;
};

QML_DECLARE_TYPEINFO(ModelHelper, QML_HAS_ATTACHED_PROPERTIES)

#endif // MODELHELPER_H
