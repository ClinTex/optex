module {
    public type FieldDefinition = {
        var fieldName:Text;
        var fieldType:Text;
    };

    public type DataSource = {
        var dataSourceName:Text;
        var fieldDefinitions:[FieldDefinition];
        var data:[[var Text]];
    };

    public type ImmutableFieldDefinition = {
        fieldName:Text;
        fieldType:Text;
    };

    public type ImmutableDataSource = {
        dataSourceName:Text;
        fieldDefinitions:[ImmutableFieldDefinition];
        data:[[Text]];
    };
}