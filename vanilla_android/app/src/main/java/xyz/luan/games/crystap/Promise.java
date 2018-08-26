package xyz.luan.games.crystap;

import android.support.annotation.NonNull;

import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

public class Promise<T> {

    public interface Consumer<T> {
        void accept(T t);
    }

    public interface Supplier<T> {
        T get();
    }

    public class Resolver {
        public void resolve(T t) {
            value = t;
            done = true;
        }
    }

    private boolean done = false;
    private T value;

    public Promise(final Consumer<Resolver> c) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                c.accept(new Resolver());
            }
        }).start();
    }

    public static void waitFor(Supplier<Boolean> s) {
        while (!s.get()) {
            sleep(10);
        }
    }

    public static void waitFor(Supplier<Boolean> s, long maxMillis) {
        long current = 0L;
        while (!s.get()) {
            sleep(10);
            current += 10;
            if (current > maxMillis) {
                break;
            }
        }
    }

    public static void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException ignored) {}
    }

    public static <T> Future<T> completed(final T t) {
        return new Future<T>() {
            @Override
            public boolean cancel(boolean b) {
                return false;
            }

            @Override
            public boolean isCancelled() {
                return false;
            }

            @Override
            public boolean isDone() {
                return true;
            }

            @Override
            public T get() {
                return t;
            }

            @Override
            public T get(long l, @NonNull TimeUnit timeUnit) {
                return t;
            }
        };
    }

    public Future<T> getFuture() {
        return new Future<T>() {
            @Override
            public boolean cancel(boolean b) {
                return false;
            }

            @Override
            public boolean isCancelled() {
                return false;
            }

            @Override
            public boolean isDone() {
                return done;
            }

            @Override
            public T get() {
                waitFor(new Supplier<Boolean>() {
                    @Override
                    public Boolean get() {
                        return done;
                    }
                });
                return value;
            }

            @Override
            public T get(long l, @NonNull TimeUnit timeUnit) {
                waitFor(new Supplier<Boolean>() {
                    @Override
                    public Boolean get() {
                        return done;
                    }
                }, timeUnit.toMillis(l));
                return value;
            }
        };
    }
}
