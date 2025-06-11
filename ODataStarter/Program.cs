using Microsoft.AspNetCore.OData;
using Microsoft.AspNetCore.OData.Routing.Controllers;
using Microsoft.OData.ModelBuilder;

var builder = WebApplication.CreateBuilder(args);

var modelBuilder = new ODataConventionModelBuilder();
modelBuilder.EntitySet<Customer>("Customers");

builder.Services
    .AddControllers()
    .AddOData(options =>
    {
        options.EnableQueryFeatures()
            .AddRouteComponents("api", modelBuilder.GetEdmModel());
    });

var app = builder.Build();

app.MapControllers();
app.UseODataRouteDebug();

app.MapGet("/", () => "Hello World!");

app.Run();

public class Customer
{
    public int Id { get; set; }
    public string Name { get; set; }
}

public class CustomersController : ODataController
{
    public IEnumerable<Customer> Get()
    {
        return new List<Customer>
        {
            new() { Id = 1, Name = "John" },
            new() { Id = 2, Name = "Jane" }
        };
    }
}