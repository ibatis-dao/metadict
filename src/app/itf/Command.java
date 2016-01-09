package app.itf;

public interface Command {
	void execute();
	void execute(Object[] params);
}
